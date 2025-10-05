import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/core/dio/dio_provider.dart';
import 'package:mongle_flutter/features/auth/data/data_sources/token_storage_service.dart';
import 'package:mongle_flutter/features/community/data/repositories/fake_issue_grain_repository_impl.dart';
import 'package:mongle_flutter/features/community/data/repositories/issue_grain_repository_impl.dart';
import 'package:mongle_flutter/features/community/data/repositories/reaction_repository_impl.dart';
import 'package:mongle_flutter/features/community/domain/entities/issue_grain.dart';
import 'package:mongle_flutter/features/community/domain/entities/reaction_models.dart';
import 'package:mongle_flutter/features/community/domain/entities/report_models.dart';
import 'package:mongle_flutter/features/community/domain/repositories/issue_grain_repository.dart';
import 'package:mongle_flutter/features/community/domain/repositories/reaction_repository.dart';
import 'package:mongle_flutter/features/community/providers/block_providers.dart';
import 'package:mongle_flutter/features/community/providers/report_providers.dart';
import 'package:equatable/equatable.dart'; // 값 기반 비교를 위해 equatable 패키지를 사용합니다.

// ✅ [추가] 구름의 종류를 명확하게 표현하는 enum
enum CloudType { static, dynamic }

// ✅ [추가] Provider.family에 전달할 파라미터 클래스
class CloudProviderParam extends Equatable {
  final String id;
  final CloudType type;

  const CloudProviderParam({required this.id, required this.type});

  @override
  List<Object?> get props => [id, type]; // id와 type이 모두 같아야 같은 객체로 취급
}

// ========================================================================
// 1. Data Layer Provider
// ========================================================================

/// [데이터 계층] 앱 전역에서 IssueGrainRepository의 구현체를 제공하는 Provider
///
/// UI(Presentation) 계층에서는 이 Provider를 통해 데이터에 접근하며,
/// 나중에 Fake에서 Real(실제 API 통신)으로 교체할 때 이 부분만 수정하면 됩니다.
final issueGrainRepositoryProvider = Provider<IssueGrainRepository>((ref) {
  // return FakeIssueGrainRepositoryImpl();
  final dio = ref.watch(dioProvider);
  final tokenStorage = ref.watch(tokenStorageServiceProvider);
  return IssueGrainRepositoryImpl(dio, tokenStorage);
});

// ========================================================================
// 2. Presentation Layer Providers
// ========================================================================

// ✅ [수정] 이 Provider는 이제 새로운 `cloudPostsProvider`로 대체되었으므로 주석 처리하거나 삭제합니다.
//    컴파일 오류를 해결하기 위해 주석 처리합니다.
/*
/// [목록용] '구름 ID'를 받아 해당 구름에 속한 이슈 알갱이 리스트를 제공하는 Provider
///
/// '읽기' 전용으로, 목록을 한번에 불러오는 경우에 사용합니다.
/// .family: 외부에서 파라미터(cloudId)를 전달받을 수 있게 해줍니다.
final issueGrainsInCloudProvider = FutureProvider.autoDispose
    .family<List<IssueGrain>, CloudProviderParam>((ref, param) async {
      // async 추가
      // [상태 감시] ref.watch를 사용해 차단된 사용자 목록을 구독합니다.
      // 이 Provider는 이제 blockedUsersProvider의 상태가 바뀔 때마다 자동으로 재실행됩니다.
      final blockedUserIds = ref.watch(blockedUsersProvider);
      final reportedContents = ref.watch(reportedContentProvider);

      final repository = ref.watch(issueGrainRepositoryProvider);
      final List<IssueGrain> allGrains;

      // ✅ [수정] 더 이상 문자열을 분석할 필요 없이, param.type으로 명확하게 분기합니다.
      switch (param.type) {
        case CloudType.static:
          allGrains = await repository.getGrainsInStaticCloud(param.id);
          break;
        case CloudType.dynamic:
          allGrains = await repository.getGrainsInDynamicCloud(param.id);
          break;
      }

      // [필터링 로직]
      // 차단된 사용자가 작성한 게시물을 제외하고 새로운 리스트를 만듭니다.
      final visibleGrains = allGrains.where((grain) {
        // ✅ 2. 차단된 사용자인지 확인
        final isBlocked = blockedUserIds.contains(grain.author.id);
        if (isBlocked) {
          return false; // 차단된 유저의 글이면 보이지 않게 처리
        }

        // ✅ 3. 내가 신고한 게시물인지 확인
        final isReported = reportedContents.any(
          (reported) =>
              reported.id == grain.postId &&
              reported.type == ReportContentType.POST,
        );
        if (isReported) {
          return false; // 내가 신고한 글이면 보이지 않게 처리
        }

        // 모든 필터링을 통과한 경우에만 보이도록 처리
        return true;
      }).toList();

      return visibleGrains;
    });
*/

/// [단일용] '알갱이 ID'를 받아 단일 이슈 알갱이의 '상태'를 관리하고, 관련 '동작'을 제공하는 Provider
///
/// FutureProvider와 달리, 불러온 데이터(상태)에 '좋아요' 같은 변경(동작)을 가할 수 있습니다.
/// .family: 외부에서 파라미터(postId)를 전달받아, 각 게시글마다 독립적인 상태를 관리하게 해줍니다.
final issueGrainProvider = StateNotifierProvider.autoDispose
    .family<IssueGrainNotifier, AsyncValue<IssueGrain>, String>((ref, postId) {
      final issueGrainRepository = ref.watch(issueGrainRepositoryProvider);
      final reactionRepository = ref.watch(reactionRepositoryProvider);
      return IssueGrainNotifier(
        issueGrainRepository,
        reactionRepository,
        postId,
      );
    });

// ========================================================================
// 3. State Notifier Class
// ========================================================================

/// '이슈 알갱이'의 상태(State)와 비즈니스 로직(Notifier)을 캡슐화한 클래스
///
/// UI는 이 Notifier에 정의된 메서드(like, dislike 등)를 호출하여 상태 변경을 요청합니다.
class IssueGrainNotifier extends StateNotifier<AsyncValue<IssueGrain>> {
  final IssueGrainRepository _issueGrainRepository;
  final ReactionRepository _reactionRepository;
  final String _postId;

  IssueGrainNotifier(
    this._issueGrainRepository,
    this._reactionRepository,
    this._postId,
  ) : super(const AsyncValue.loading()) {
    _fetchIssueGrain();
  }

  /// 게시글의 초기 데이터를 서버로부터 가져옵니다.
  /// 이제 서버가 myReaction을 주기 때문에 이 함수가 호출되면 초기 버튼 상태가 정확하게 설정됩니다.
  Future<void> _fetchIssueGrain() async {
    try {
      final grain = await _issueGrainRepository.getIssueGrainById(_postId);
      if (mounted) {
        // 위젯이 화면에 아직 있는지 확인
        state = AsyncValue.data(grain);
      }
    } catch (e, s) {
      if (mounted) {
        state = AsyncValue.error(e, s);
      }
    }
  }

  /// '좋아요' 버튼을 눌렀을 때의 로직
  Future<void> like() async {
    // 현재 '좋아요' 상태가 아니었다면 'LIKE'로, 이미 '좋아요' 상태였다면 취소의 의미로 'LIKE'를 다시 보냅니다.
    await _updateReaction(ReactionType.LIKE);
  }

  /// '싫어요' 버튼을 눌렀을 때의 로직
  Future<void> dislike() async {
    // 현재 '싫어요' 상태가 아니었다면 'DISLIKE'로, 이미 '싫어요' 상태였다면 취소의 의미로 'DISLIKE'를 다시 보냅니다.
    await _updateReaction(ReactionType.DISLIKE);
  }

  /// 공통 반응 업데이트 로직 (낙관적 UI 적용)
  Future<void> _updateReaction(ReactionType reactionType) async {
    // 현재 상태가 데이터가 아니면 (로딩/에러) 아무것도 하지 않습니다.
    if (state.valueOrNull == null) return;

    // 1. [상태 저장] API 요청 실패 시 되돌아갈 현재 상태를 백업합니다.
    final oldState = state.value!;

    // 2. [낙관적 업데이트] 서버 응답을 기다리지 않고 UI 상태를 즉시 변경합니다.
    state = AsyncValue.data(_calculateOptimisticState(oldState, reactionType));

    try {
      // 3. [API 호출] 백그라운드에서 서버에 실제 요청을 보냅니다.
      final serverResponse = await _reactionRepository.updateReaction(
        targetType: 'posts', // 게시글이므로 'posts'
        targetId: _postId,
        reactionType: reactionType,
      );

      // 4. [상태 동기화] API 호출 성공 시, 서버가 보내준 최종 카운트로 상태를 업데이트하여 동기화합니다.
      // myReaction 상태는 이미 낙관적으로 변경되었으므로, 카운트만 동기화합니다.
      if (mounted) {
        state = AsyncValue.data(
          state.value!.copyWith(
            likeCount: serverResponse.likeCount,
            dislikeCount: serverResponse.dislikeCount,
          ),
        );
      }
    } catch (e) {
      // 5. [롤백] API 호출 실패 시, 1번에서 백업해둔 원래 상태로 UI를 되돌립니다.
      if (mounted) {
        state = AsyncValue.data(oldState);
      }
      // (선택) 사용자에게 에러 스낵바를 보여줄 수도 있습니다.
      print("Reaction update failed: $e");
    }
  }

  /// 낙관적 UI 상태를 계산하는 헬퍼 함수 (내부 로직)
  IssueGrain _calculateOptimisticState(
    IssueGrain currentState,
    ReactionType newReaction,
  ) {
    int newLikeCount = currentState.likeCount;
    int newDislikeCount = currentState.dislikeCount;
    ReactionType? finalReaction;

    final currentReaction = currentState.myReaction;

    // A. 현재 반응과 누른 버튼이 같은 경우 (토글 -> 취소)
    if (currentReaction == newReaction) {
      if (newReaction == ReactionType.LIKE) newLikeCount--;
      if (newReaction == ReactionType.DISLIKE) newDislikeCount--;
      finalReaction = null;
    }
    // B. 현재 반응과 누른 버튼이 다른 경우 (변경 또는 새로 누름)
    else {
      // B-1. 기존 반응이 있었다면 먼저 카운트를 되돌린다.
      if (currentReaction == ReactionType.LIKE) newLikeCount--;
      if (currentReaction == ReactionType.DISLIKE) newDislikeCount--;

      // B-2. 새로운 반응의 카운트를 올린다.
      if (newReaction == ReactionType.LIKE) newLikeCount++;
      if (newReaction == ReactionType.DISLIKE) newDislikeCount++;
      finalReaction = newReaction;
    }

    return currentState.copyWith(
      likeCount: newLikeCount,
      dislikeCount: newDislikeCount,
      myReaction: finalReaction,
    );
  }
}

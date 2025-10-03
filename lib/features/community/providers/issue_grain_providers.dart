import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/core/dio/dio_provider.dart';
import 'package:mongle_flutter/features/auth/data/data_sources/token_storage_service.dart';
import 'package:mongle_flutter/features/community/data/repositories/fake_issue_grain_repository_impl.dart';
import 'package:mongle_flutter/features/community/data/repositories/issue_grain_repository_impl.dart';
import 'package:mongle_flutter/features/community/domain/entities/issue_grain.dart';
import 'package:mongle_flutter/features/community/domain/entities/report_models.dart';
import 'package:mongle_flutter/features/community/domain/repositories/issue_grain_repository.dart';
import 'package:mongle_flutter/features/community/providers/block_providers.dart';
import 'package:mongle_flutter/features/community/providers/report_providers.dart';

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

/// [목록용] '구름 ID'를 받아 해당 구름에 속한 이슈 알갱이 리스트를 제공하는 Provider
///
/// '읽기' 전용으로, 목록을 한번에 불러오는 경우에 사용합니다.
/// .family: 외부에서 파라미터(cloudId)를 전달받을 수 있게 해줍니다.
final issueGrainsInCloudProvider = FutureProvider.autoDispose
    .family<List<IssueGrain>, String>((ref, cloudId) async {
      // async 추가
      // [상태 감시] ref.watch를 사용해 차단된 사용자 목록을 구독합니다.
      // 이 Provider는 이제 blockedUsersProvider의 상태가 바뀔 때마다 자동으로 재실행됩니다.
      final blockedUserIds = ref.watch(blockedUsersProvider);
      final reportedContents = ref.watch(reportedContentProvider);

      final repository = ref.watch(issueGrainRepositoryProvider);
      final allGrains = await repository.getIssueGrainsInCloud(cloudId);

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

/// [단일용] '알갱이 ID'를 받아 단일 이슈 알갱이의 '상태'를 관리하고, 관련 '동작'을 제공하는 Provider
///
/// FutureProvider와 달리, 불러온 데이터(상태)에 '좋아요' 같은 변경(동작)을 가할 수 있습니다.
/// .family: 외부에서 파라미터(postId)를 전달받아, 각 게시글마다 독립적인 상태를 관리하게 해줍니다.
final issueGrainProvider = StateNotifierProvider.autoDispose
    .family<IssueGrainNotifier, AsyncValue<IssueGrain>, String>((ref, postId) {
      final repository = ref.watch(issueGrainRepositoryProvider);
      return IssueGrainNotifier(repository, postId);
    });

// ========================================================================
// 3. State Notifier Class
// ========================================================================

/// '이슈 알갱이'의 상태(State)와 비즈니스 로직(Notifier)을 캡슐화한 클래스
///
/// UI는 이 Notifier에 정의된 메서드(like, dislike 등)를 호출하여 상태 변경을 요청합니다.
class IssueGrainNotifier extends StateNotifier<AsyncValue<IssueGrain>> {
  final IssueGrainRepository _repository;
  final String _postId;

  IssueGrainNotifier(this._repository, this._postId)
    : super(const AsyncValue.loading()) {
    _fetchIssueGrain();
  }

  Future<void> _fetchIssueGrain() async {
    try {
      final grain = await _repository.getIssueGrainById(_postId);
      if (mounted) {
        state = AsyncValue.data(grain);
      }
    } catch (e, s) {
      if (mounted) {
        state = AsyncValue.error(e, s);
      }
    }
  }

  // '좋아요' 기능을 처리하는 외부 공개 함수
  Future<void> like() async {
    // Optimistic UI 적용: 서버 응답을 기다리지 않고 UI를 즉시 업데이트
    state.whenData((grain) {
      state = AsyncValue.data(grain.copyWith(likeCount: grain.likeCount + 1));
    });

    try {
      await _repository.likeIssueGrain(_postId);
      // 성공 시에는 별도 처리 없음 (이미 UI는 긍정적으로 업데이트됨)
      // 실제 API라면 여기서 반환된 최신 데이터로 state를 한번 더 갱신해줄 수 있습니다.
    } catch (e) {
      // API 호출 실패 시, 이전 상태로 UI를 되돌림 (Rollback)
      state.whenData((grain) {
        state = AsyncValue.data(grain.copyWith(likeCount: grain.likeCount - 1));
      });
    }
  }

  Future<void> dislike() async {
    state.whenData((grain) {
      state = AsyncValue.data(
        grain.copyWith(dislikeCount: grain.dislikeCount + 1),
      );
    });
    try {
      await _repository.dislikeIssueGrain(_postId);
    } catch (e) {
      state.whenData((grain) {
        state = AsyncValue.data(
          grain.copyWith(dislikeCount: grain.dislikeCount - 1),
        );
      });
    }
  }
}

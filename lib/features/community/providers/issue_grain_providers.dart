import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/core/dio/dio_provider.dart';
import 'package:mongle_flutter/features/auth/data/data_sources/token_storage_service.dart';
import 'package:mongle_flutter/features/community/data/repositories/issue_grain_repository_impl.dart';
import 'package:mongle_flutter/features/community/data/repositories/reaction_repository_impl.dart';
import 'package:mongle_flutter/features/community/domain/entities/issue_grain.dart';
import 'package:mongle_flutter/features/community/domain/entities/paginated_posts.dart';
import 'package:mongle_flutter/features/community/domain/entities/reaction_models.dart';
import 'package:mongle_flutter/features/community/domain/entities/report_models.dart';
import 'package:mongle_flutter/features/community/domain/repositories/issue_grain_repository.dart';
import 'package:mongle_flutter/features/community/domain/repositories/reaction_repository.dart';
import 'package:mongle_flutter/features/community/providers/block_providers.dart';
import 'package:mongle_flutter/features/community/providers/report_providers.dart';

// 구름의 종류를 명확하게 표현하는 enum
enum CloudType { static, dynamic }

// Provider.family에 전달할 파라미터 클래스
class CloudProviderParam extends Equatable {
  final String id;
  final CloudType type;

  const CloudProviderParam({required this.id, required this.type});

  @override
  List<Object?> get props => [id, type];
}

// ========================================================================
// 1. Data Layer Provider
// ========================================================================

final issueGrainRepositoryProvider = Provider<IssueGrainRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final tokenStorage = ref.watch(tokenStorageServiceProvider);
  return IssueGrainRepositoryImpl(dio, tokenStorage);
});

// ========================================================================
// 2. Presentation Layer Providers
// ========================================================================

// [삭제] 기존 FutureProvider는 삭제합니다.
/*
final issueGrainsInCloudProvider = FutureProvider.autoDispose
    .family<List<IssueGrain>, CloudProviderParam>((ref, param) async {
  // ... 기존 코드 ...
});
*/

// [신규] 페이지네이션 상태를 관리하는 StateNotifier
class PaginatedGrainsNotifier
    extends StateNotifier<AsyncValue<PaginatedPosts>> {
  final IssueGrainRepository _repository;
  final CloudProviderParam _param;
  final Ref _ref;

  PaginatedGrainsNotifier(this._repository, this._param, this._ref)
    : super(const AsyncValue.loading()) {
    _fetchFirstPage();
  }

  Future<void> _fetchFirstPage() async {
    try {
      state = const AsyncValue.loading();
      final paginatedPosts = await _fetchPage(cursor: null);
      state = AsyncValue.data(paginatedPosts);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> fetchNextPage() async {
    // 로딩 중이거나, 데이터가 없거나, 마지막 페이지면 실행하지 않음
    if (state.isLoading ||
        state.isRefreshing ||
        !(state.value?.hasNext ?? false)) {
      return;
    }

    final currentState = state.value!;

    // 다음 페이지를 로딩 중임을 상태에 반영할 수 있습니다 (UI에 로딩 인디케이터 표시용).
    // 예: state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = await _fetchPage(cursor: currentState.nextCursor);
      // 현재 상태에 새로운 게시물 목록을 추가하여 상태를 업데이트합니다.
      state = AsyncValue.data(
        nextPage.copyWith(posts: [...currentState.posts, ...nextPage.posts]),
      );
    } catch (e) {
      // 에러가 발생해도 앱이 멈추지 않도록 처리합니다.
      print('Failed to fetch next page of grains: $e');
      // 필요하다면 여기서 사용자에게 에러를 알리는 로직을 추가할 수 있습니다.
    }
  }

  // 필터링 로직을 포함한 공통 페이지 fetch 함수
  Future<PaginatedPosts> _fetchPage({String? cursor}) async {
    final PaginatedPosts result;
    switch (_param.type) {
      case CloudType.static:
        result = await _repository.getGrainsInStaticCloud(
          placeId: _param.id,
          cursor: cursor,
        );
        break;
      case CloudType.dynamic:
        result = await _repository.getGrainsInDynamicCloud(
          cloudId: _param.id,
          cursor: cursor,
        );
        break;
    }

    final blockedUserIds = _ref.read(blockedUsersProvider);
    final reportedContents = _ref.read(reportedContentProvider);

    if (blockedUserIds.isEmpty && reportedContents.isEmpty) {
      return result;
    }

    final visiblePosts = result.posts.where((grain) {
      final isBlocked = blockedUserIds.contains(grain.author.id);
      if (isBlocked) return false;

      final isReported = reportedContents.any(
        (reported) =>
            reported.id == grain.postId &&
            reported.type == ReportContentType.POST,
      );
      if (isReported) return false;

      return true;
    }).toList();

    return result.copyWith(posts: visiblePosts);
  }
}

// [신규] 위 Notifier를 UI에 제공하는 StateNotifierProvider
final paginatedGrainsProvider = StateNotifierProvider.autoDispose
    .family<
      PaginatedGrainsNotifier,
      AsyncValue<PaginatedPosts>,
      CloudProviderParam
    >((ref, param) {
      // 차단/신고 목록이 변경되면 이 Provider가 자동으로 재실행되어 목록을 새로고침합니다.
      ref.watch(blockedUsersProvider);
      ref.watch(reportedContentProvider);

      final repository = ref.watch(issueGrainRepositoryProvider);
      return PaginatedGrainsNotifier(repository, param, ref);
    });

/// [유지] 단일 게시물 상세 정보를 위한 issueGrainProvider는 그대로 유지합니다.
/// GrainDetailScreen, MapScreen 등에서 계속 사용됩니다.
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
// 3. State Notifier Class for a single grain
// ========================================================================

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

  Future<void> _fetchIssueGrain() async {
    try {
      final grain = await _issueGrainRepository.getIssueGrainById(_postId);
      if (mounted) {
        state = AsyncValue.data(grain);
      }
    } catch (e, s) {
      if (mounted) {
        state = AsyncValue.error(e, s);
      }
    }
  }

  Future<void> like() async {
    await _updateReaction(ReactionType.LIKE);
  }

  Future<void> dislike() async {
    await _updateReaction(ReactionType.DISLIKE);
  }

  Future<void> _updateReaction(ReactionType reactionType) async {
    if (state.valueOrNull == null) return;
    final oldState = state.value!;
    state = AsyncValue.data(_calculateOptimisticState(oldState, reactionType));

    try {
      final serverResponse = await _reactionRepository.updateReaction(
        targetType: 'posts',
        targetId: _postId,
        reactionType: reactionType,
      );
      if (mounted) {
        state = AsyncValue.data(
          state.value!.copyWith(
            likeCount: serverResponse.likeCount,
            dislikeCount: serverResponse.dislikeCount,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        state = AsyncValue.data(oldState);
      }
      print("Reaction update failed: $e");
    }
  }

  IssueGrain _calculateOptimisticState(
    IssueGrain currentState,
    ReactionType newReaction,
  ) {
    int newLikeCount = currentState.likeCount;
    int newDislikeCount = currentState.dislikeCount;
    ReactionType? finalReaction;
    final currentReaction = currentState.myReaction;

    if (currentReaction == newReaction) {
      if (newReaction == ReactionType.LIKE) newLikeCount--;
      if (newReaction == ReactionType.DISLIKE) newDislikeCount--;
      finalReaction = null;
    } else {
      if (currentReaction == ReactionType.LIKE) newLikeCount--;
      if (currentReaction == ReactionType.DISLIKE) newDislikeCount--;
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

// ========================================================================
// 4. [신규] '좋아요/싫어요' 액션 전용 Notifier 및 Provider
// ========================================================================

/// '좋아요/싫어요' 기능만 담당하는 가볍고 "차가운(Cold)" Notifier 클래스.
/// 이 클래스는 StateNotifier를 상속하지 않는데, UI가 구독할 상태(state)를 가지지 않고
/// 오직 '행동(action)'만 수행하기 때문입니다.
class ReactionNotifier {
  final ReactionRepository _repository;
  final String _postId;

  // 생성자: 필요한 부품들(repository, postId)을 전달받아 저장만 합니다.
  //         API 호출과 같은 어떠한 동작도 하지 않으므로 "안전"합니다.
  ReactionNotifier(this._repository, this._postId);

  // '좋아요' 버튼을 눌렀을 때 UI가 호출할 함수
  Future<ReactionResponse> like() async {
    return await _updateReaction(ReactionType.LIKE);
  }

  // '싫어요' 버튼을 눌렀을 때 UI가 호출할 함수
  Future<ReactionResponse> dislike() async {
    return await _updateReaction(ReactionType.DISLIKE);
  }

  // 실제 API를 호출하는 내부 비공개 함수
  Future<ReactionResponse> _updateReaction(ReactionType type) async {
    return await _repository.updateReaction(
      targetType: 'posts',
      targetId: _postId,
      reactionType: type,
    );
  }
}

/// 위 ReactionNotifier를 UI에 제공하는 Provider.
final reactionNotifierProvider = Provider.autoDispose
    .family<ReactionNotifier, String>((ref, postId) {
      // .family를 사용하여 각 postId마다 독립적인 ReactionNotifier를 생성합니다.

      // 다른 Provider를 통해 ReactionRepository의 인스턴스를 가져옵니다.
      final reactionRepository = ref.watch(reactionRepositoryProvider);

      // postId와 repository를 주입하여 ReactionNotifier 인스턴스를 생성 후 반환합니다.
      return ReactionNotifier(reactionRepository, postId);
    });

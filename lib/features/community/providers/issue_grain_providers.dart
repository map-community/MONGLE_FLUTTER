import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/core/dio/dio_provider.dart';
import 'package:mongle_flutter/features/auth/data/data_sources/token_storage_service.dart';
import 'package:mongle_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:mongle_flutter/features/auth/providers/user_provider.dart';
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

  /// 게시글을 목록에서 즉시 제거하는 메서드 (낙관적 UI 업데이트)
  Future<bool> deletePostOptimistically(String postId, String authorId) async {
    // [1] 현재 상태 확인
    final currentState = state.valueOrNull;
    if (currentState == null) return false;

    // [2] 권한 확인
    final currentUserId = await _ref.read(currentMemberIdProvider.future);
    if (currentUserId != authorId) {
      print("삭제 권한이 없습니다.");
      return false;
    }

    // [3] 현재 상태를 백업 (실패 시 롤백용)
    final backupState = currentState;

    // [4] 낙관적 UI 업데이트: 목록에서 해당 게시글 제거
    final newPosts = currentState.posts
        .where((post) => post.postId != postId)
        .toList();

    // [5] UI 즉시 업데이트
    state = AsyncValue.data(currentState.copyWith(posts: newPosts));

    // [6] 백그라운드에서 서버 요청
    try {
      await _repository.deletePost(postId);
      // 성공! UI는 이미 업데이트됨
      return true;
    } catch (e) {
      // [7] 실패 시 롤백
      if (mounted) {
        state = AsyncValue.data(backupState);
      }
      print("게시글 삭제 실패: $e");
      return false;
    }
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
      ref.watch(authProvider);

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
      ref.watch(authProvider);

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
// 4. [수정] '좋아요/싫어요' 액션 및 상태 관리 Provider
// ========================================================================

/// ⭐ StateNotifier로 변경하여 상태 관리
class ReactionNotifier extends StateNotifier<ReactionState> {
  final ReactionRepository _repository;
  final String _postId;

  // ⭐ 생성자 파라미터 간소화 (initialGrain만 받음)
  ReactionNotifier(this._repository, this._postId, ReactionState initialState)
    : super(initialState);

  /// 좋아요 토글
  Future<ReactionResponse> like() async {
    if (state.isUpdating) {
      return ReactionResponse(
        likeCount: state.likeCount,
        dislikeCount: state.dislikeCount,
      );
    }

    final oldState = state;
    final wasLiked = state.myReaction == ReactionType.LIKE;

    // 낙관적 업데이트
    if (wasLiked) {
      state = state.copyWith(
        likeCount: state.likeCount - 1,
        myReaction: null,
        isUpdating: true,
      );
    } else {
      int newLikeCount = state.likeCount + 1;
      int newDislikeCount = state.dislikeCount;

      if (state.myReaction == ReactionType.DISLIKE) {
        newDislikeCount--;
      }

      state = state.copyWith(
        likeCount: newLikeCount,
        dislikeCount: newDislikeCount,
        myReaction: ReactionType.LIKE,
        isUpdating: true,
      );
    }

    try {
      final response = await _updateReaction(ReactionType.LIKE);

      if (mounted) {
        state = state.copyWith(
          likeCount: response.likeCount,
          dislikeCount: response.dislikeCount,
          isUpdating: false,
        );
      }

      return response;
    } catch (e) {
      if (mounted) {
        state = oldState;
      }
      rethrow;
    }
  }

  /// 싫어요 토글
  Future<ReactionResponse> dislike() async {
    if (state.isUpdating) {
      return ReactionResponse(
        likeCount: state.likeCount,
        dislikeCount: state.dislikeCount,
      );
    }

    final oldState = state;
    final wasDisliked = state.myReaction == ReactionType.DISLIKE;

    // 낙관적 업데이트
    if (wasDisliked) {
      state = state.copyWith(
        dislikeCount: state.dislikeCount - 1,
        myReaction: null,
        isUpdating: true,
      );
    } else {
      int newLikeCount = state.likeCount;
      int newDislikeCount = state.dislikeCount + 1;

      if (state.myReaction == ReactionType.LIKE) {
        newLikeCount--;
      }

      state = state.copyWith(
        likeCount: newLikeCount,
        dislikeCount: newDislikeCount,
        myReaction: ReactionType.DISLIKE,
        isUpdating: true,
      );
    }

    try {
      final response = await _updateReaction(ReactionType.DISLIKE);

      if (mounted) {
        state = state.copyWith(
          likeCount: response.likeCount,
          dislikeCount: response.dislikeCount,
          isUpdating: false,
        );
      }

      return response;
    } catch (e) {
      if (mounted) {
        state = oldState;
      }
      rethrow;
    }
  }

  Future<ReactionResponse> _updateReaction(ReactionType type) async {
    return await _repository.updateReaction(
      targetType: 'posts',
      targetId: _postId,
      reactionType: type,
    );
  }
}

// ⭐ [중요] 파라미터를 (postId, grain) 튜플로 변경
class ReactionProviderParam extends Equatable {
  final String postId;
  final IssueGrain grain;

  const ReactionProviderParam({required this.postId, required this.grain});

  @override
  List<Object?> get props => [postId]; // ⭐ postId로만 비교 (grain 변경은 무시)
}

/// ⭐ [변경] 파라미터를 grain 포함으로 변경
final reactionNotifierProvider = StateNotifierProvider.autoDispose
    .family<ReactionNotifier, ReactionState, ReactionProviderParam>((
      ref,
      param,
    ) {
      final reactionRepository = ref.watch(reactionRepositoryProvider);

      final initialState = ReactionState(
        likeCount: param.grain.likeCount,
        dislikeCount: param.grain.dislikeCount,
        myReaction: param.grain.myReaction,
      );

      return ReactionNotifier(reactionRepository, param.postId, initialState);
    });

// ========================================================================
// ✨ 5. [신규] 게시글 '삭제' 액션 전용 Notifier 및 Provider
// ========================================================================

/// 게시글 삭제 명령(Command)만 처리하는 Notifier. UI 상태는 관리하지 않습니다.
class PostCommandNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  final IssueGrainRepository _issueGrainRepository;

  PostCommandNotifier(this._ref)
    : _issueGrainRepository = _ref.read(issueGrainRepositoryProvider),
      super(const AsyncData(null));

  /// 게시글을 삭제하는 메서드
  Future<bool> deletePost(String postId, String authorId) async {
    // [권한 확인] 현재 로그인한 사용자의 ID를 가져옵니다.
    final currentUserId = await _ref.read(currentMemberIdProvider.future);
    if (currentUserId != authorId) {
      print("삭제 권한이 없습니다.");
      // 사용자에게 스낵바 등으로 실패를 알려줄 수 있습니다.
      return false;
    }

    state = const AsyncValue.loading();
    try {
      await _issueGrainRepository.deletePost(postId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      print("게시글 삭제 실패: $e");
      return false;
    }
  }
}

/// PostCommandNotifier의 인스턴스를 제공하는 Provider
final postCommandProvider =
    StateNotifierProvider.autoDispose<PostCommandNotifier, AsyncValue<void>>(
      (ref) => PostCommandNotifier(ref),
    );

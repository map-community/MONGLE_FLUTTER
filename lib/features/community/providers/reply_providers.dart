// lib/features/community/providers/reply_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mongle_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:mongle_flutter/features/community/data/repositories/reaction_repository_impl.dart';
import 'package:mongle_flutter/features/community/domain/entities/comment.dart';
import 'package:mongle_flutter/features/community/domain/entities/paginated_comments.dart';
import 'package:mongle_flutter/features/community/domain/entities/reaction_models.dart';
import 'package:mongle_flutter/features/community/domain/repositories/reaction_repository.dart';
import 'package:mongle_flutter/features/community/providers/comment_providers.dart';

part 'reply_providers.freezed.dart';

// ========================================================================
// 1. 대댓글 상태를 위한 데이터 클래스 (State)
// ========================================================================

/// 각 부모 댓글에 속한 대댓글 목록의 상태를 관리하는 데이터 클래스입니다.
@freezed
abstract class RepliesState with _$RepliesState {
  const factory RepliesState({
    /// 현재 로드된 대댓글 목록
    @Default([]) List<Comment> replies,

    /// 다음 페이지를 로드하기 위한 커서
    String? nextCursor,

    /// 더 불러올 대댓글이 있는지 여부
    @Default(true) bool hasNext,

    /// '더보기' 로딩 중인지 여부
    @Default(false) bool isLoadingMore,
  }) = _RepliesState;
}

// ========================================================================
// 2. 대댓글 상태 관리자 (State Notifier)
// ========================================================================

/// 특정 부모 댓글(`parentCommentId`)에 대한 대댓글의 상태와 비즈니스 로직을 관리합니다.
class RepliesNotifier extends StateNotifier<AsyncValue<RepliesState>> {
  final Ref _ref;
  final String _parentCommentId;
  final ReactionRepository _reactionRepository;

  RepliesNotifier(this._ref, this._parentCommentId)
    : _reactionRepository = _ref.read(reactionRepositoryProvider),
      super(const AsyncValue.loading()) {
    _fetchInitialReplies();
  }

  /// 정책에 따라, 초기에 보여줄 대댓글 3개를 불러옵니다.
  Future<void> _fetchInitialReplies() async {
    try {
      final repo = _ref.read(commentRepositoryProvider);
      // 서버 API를 호출하여 대댓글 데이터를 가져옵니다.
      final result = await repo.getReplies(
        parentCommentId: _parentCommentId,
        size: 3,
      );

      // 위젯이 아직 화면에 있다면, 상태를 데이터로 업데이트합니다.
      if (mounted) {
        state = AsyncValue.data(
          RepliesState(
            replies: result.comments,
            nextCursor: result.nextCursor,
            hasNext: result.hasNext,
          ),
        );
      }
    } catch (e, s) {
      // 에러 발생 시 상태를 에러로 업데이트합니다.
      if (mounted) {
        state = AsyncValue.error(e, s);
      }
    }
  }

  /// '더보기' 버튼을 눌렀을 때 다음 대댓글 3개를 불러옵니다.
  Future<void> fetchMoreReplies() async {
    // 이미 로딩 중이거나, 다음 페이지가 없거나, 현재 상태가 에러이면 실행하지 않습니다.
    if (state.value?.isLoadingMore ??
        true || !(state.value?.hasNext ?? false) || state.hasError) {
      return;
    }

    // '더보기 로딩 중' 상태로 변경하여 UI에 로딩 인디케이터를 표시하게 합니다.
    state = AsyncValue.data(state.value!.copyWith(isLoadingMore: true));

    try {
      final repo = _ref.read(commentRepositoryProvider);
      final currentState = state.value!;

      // 커서 값을 사용하여 다음 페이지를 요청합니다.
      final result = await repo.getReplies(
        parentCommentId: _parentCommentId,
        size: 3,
        cursor: currentState.nextCursor,
      );

      if (mounted) {
        // 기존 목록에 새로 불러온 목록을 추가하여 상태를 업데이트하고, 로딩 상태를 해제합니다.
        state = AsyncValue.data(
          currentState.copyWith(
            replies: [...currentState.replies, ...result.comments],
            nextCursor: result.nextCursor,
            hasNext: result.hasNext,
            isLoadingMore: false,
          ),
        );
      }
    } catch (e, s) {
      // 에러 발생 시에도 로딩 상태는 해제해주는 것이 좋습니다.
      if (mounted) {
        state = AsyncValue.data(state.value!.copyWith(isLoadingMore: false));
        // 여기에 SnackBar 등으로 사용자에게 '더보기에 실패했습니다'라고 알려주는 로직을 추가할 수 있습니다.
        print('대댓글 더보기 실패: $e');
      }
    }
  }

  Future<void> like(String replyId) async {
    await _updateReaction(replyId, ReactionType.LIKE);
  }

  Future<void> dislike(String replyId) async {
    await _updateReaction(replyId, ReactionType.DISLIKE);
  }

  Future<void> _updateReaction(
    String replyId,
    ReactionType reactionType,
  ) async {
    if (state.valueOrNull == null) return;

    final oldState = state.value!;

    final newReplies = oldState.replies.map((reply) {
      if (reply.commentId == replyId) {
        return _calculateOptimisticState(reply, reactionType);
      }
      return reply;
    }).toList();

    state = AsyncValue.data(oldState.copyWith(replies: newReplies));

    try {
      final currentReply = oldState.replies.firstWhere(
        (r) => r.commentId == replyId,
      );
      final typeToSend = currentReply.myReaction == reactionType
          ? reactionType
          : reactionType;

      final serverResponse = await _reactionRepository.updateReaction(
        targetType: 'comments',
        targetId: replyId,
        reactionType: typeToSend,
      );

      if (mounted) {
        final finalReplies = state.value!.replies.map((reply) {
          if (reply.commentId == replyId) {
            return reply.copyWith(
              likeCount: serverResponse.likeCount,
              dislikeCount: serverResponse.dislikeCount,
            );
          }
          return reply;
        }).toList();
        state = AsyncValue.data(state.value!.copyWith(replies: finalReplies));
      }
    } catch (e) {
      if (mounted) {
        state = AsyncValue.data(oldState);
      }
      print("Reply Reaction update failed: $e");
    }
  }

  Comment _calculateOptimisticState(
    Comment currentReply,
    ReactionType newReaction,
  ) {
    int newLikeCount = currentReply.likeCount;
    int newDislikeCount = currentReply.dislikeCount;
    ReactionType? finalReaction;

    final currentReaction = currentReply.myReaction;

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

    return currentReply.copyWith(
      likeCount: newLikeCount,
      dislikeCount: newDislikeCount,
      myReaction: finalReaction,
    );
  }
}

// ========================================================================
// 3. 프로바이더 (Provider)
// ========================================================================

/// UI 위젯이 RepliesNotifier에 접근할 수 있도록 해주는 Provider입니다.
///
/// `.family`를 사용하여, 부모 댓글의 ID(`String`)를 파라미터로 받아
/// 각 댓글마다 독립적인 대댓글 상태를 관리할 수 있게 합니다.
final repliesProvider = StateNotifierProvider.autoDispose
    .family<RepliesNotifier, AsyncValue<RepliesState>, String>((
      ref,
      parentCommentId,
    ) {
      // ✨ [추가] 인증 상태가 변경되면 이 프로바이더가 자동으로 재실행됩니다.
      ref.watch(authProvider);

      return RepliesNotifier(ref, parentCommentId);
    });

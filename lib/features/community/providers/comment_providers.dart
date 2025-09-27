import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/community/data/repositories/fake_comment_repository_impl.dart';
import 'package:mongle_flutter/features/community/data/repositories/mock_comment_data.dart';
import 'package:mongle_flutter/features/community/domain/entities/comment.dart';
import 'package:mongle_flutter/features/community/domain/entities/paginated_comments.dart';
import 'package:mongle_flutter/features/community/domain/repositories/comment_repository.dart';

// --- Data Layer Provider ---
final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return FakeCommentRepositoryImpl();
});

// --- State Management Layer Provider  ---

/// CommentNotifier를 UI에 제공하는 Provider입니다.
/// .family를 사용하여 postId별로 독립적인 상태를 관리합니다.
final commentProvider = StateNotifierProvider.autoDispose
    .family<CommentNotifier, AsyncValue<PaginatedComments>, String>((
      ref,
      postId,
    ) {
      final repository = ref.watch(commentRepositoryProvider);
      return CommentNotifier(repository: repository, postId: postId);
    });

/// 특정 게시글의 댓글 상태와 비즈니스 로직을 관리하는 클래스입니다.
class CommentNotifier extends StateNotifier<AsyncValue<PaginatedComments>> {
  final CommentRepository _repository;
  final String _postId;

  CommentNotifier({
    required CommentRepository repository,
    required String postId,
  }) : _repository = repository,
       _postId = postId,
       super(const AsyncValue.loading()) {
    _fetchFirstPage();
  }

  // '답글 모드'로 상태를 전환하는 메서드
  void enterReplyMode(Comment comment) {
    if (state.valueOrNull?.isSubmitting == true) return; // 전송 중에는 모드 변경 방지
    state = AsyncValue.data(state.value!.copyWith(replyingTo: comment));
  }

  // '답글 모드'를 해제하고 일반 댓글 모드로 돌아가는 메서드
  void exitReplyMode() {
    state = AsyncValue.data(state.value!.copyWith(replyingTo: null));
  }

  /// 첫 페이지의 댓글을 불러옵니다.
  Future<void> _fetchFirstPage() async {
    // ✨ isSubmitting 상태를 유지하며 데이터를 가져오기 위해 로딩 상태를 직접 관리합니다.
    final previousState = state.valueOrNull;
    try {
      final paginatedComments = await _repository.getComments(postId: _postId);
      if (mounted) {
        // 기존의 replyingTo 상태를 유지하면서 댓글 목록을 갱신합니다.
        state = AsyncValue.data(
          paginatedComments.copyWith(replyingTo: previousState?.replyingTo),
        );
      }
    } catch (e, s) {
      if (mounted) {
        state = AsyncValue.error(e, s);
      }
    }
  }

  /// 다음 페이지의 댓글을 불러옵니다 (무한 스크롤).
  Future<void> fetchNextPage() async {
    if (!state.hasValue || !state.value!.hasNext || state.value!.isSubmitting) {
      return;
    }

    final currentState = state.value!;
    // ✨ 다음 페이지 로딩 중임을 알리기 위해 isSubmitting을 잠시 true로 설정
    state = AsyncValue.data(currentState.copyWith(isSubmitting: true));

    try {
      final nextPageData = await _repository.getComments(
        postId: _postId,
        cursor: currentState.nextCursor,
      );

      if (mounted) {
        state = AsyncValue.data(
          currentState.copyWith(
            comments: [...currentState.comments, ...nextPageData.comments],
            nextCursor: nextPageData.nextCursor,
            hasNext: nextPageData.hasNext,
            isSubmitting: false, // ✨ 로딩 완료 후 false로 복원
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // ✨ 실패 시에도 false로 복원
        state = AsyncValue.data(currentState.copyWith(isSubmitting: false));
      }
      print('댓글 다음 페이지 로딩 실패: $e');
    }
  }

  Future<void> addComment(String content) async {
    final previousState = state.valueOrNull;
    if (previousState == null || previousState.isSubmitting) return;

    final newComment = Comment(
      commentId: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      author: mockCurrentUser,
      createdAt: DateTime.now(),
    );

    // ✨ 1. UI를 즉시 업데이트하면서, isSubmitting 상태를 true로 설정합니다.
    state = AsyncValue.data(
      previousState.copyWith(
        comments: [newComment, ...previousState.comments],
        isSubmitting: true,
      ),
    );

    try {
      await _repository.addComment(
        postId: _postId,
        content: content,
        author: mockCurrentUser,
      );
      // ✨ 2. 성공 후 목록을 새로고침하면, isSubmitting은 자동으로 기본값(false)으로 돌아옵니다.
      await _fetchFirstPage();
    } catch (e) {
      // ✨ 3. 실패 시, 이전 상태로 되돌리면서 isSubmitting을 false로 풀어줍니다.
      if (mounted) {
        state = AsyncValue.data(previousState.copyWith(isSubmitting: false));
      }
    }
  }

  Future<void> addReply(String parentCommentId, String content) async {
    exitReplyMode();
    final previousState = state.valueOrNull;
    if (previousState == null || previousState.isSubmitting) return;

    final newReply = Comment(
      commentId: 'temp_reply_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      author: mockCurrentUser,
      createdAt: DateTime.now(),
    );

    final updatedComments = previousState.comments.map((comment) {
      if (comment.commentId == parentCommentId) {
        return comment.copyWith(replies: [...comment.replies, newReply]);
      }
      return comment;
    }).toList();

    // ✨ 1. UI를 업데이트하면서 isSubmitting을 true로 설정합니다.
    state = AsyncValue.data(
      previousState.copyWith(comments: updatedComments, isSubmitting: true),
    );

    try {
      await _repository.addReply(
        parentCommentId: parentCommentId,
        content: content,
        author: mockCurrentUser,
      );
      // ✨ 2. 성공 시 목록 새로고침
      await _fetchFirstPage();
    } catch (e) {
      // ✨ 3. 실패 시 isSubmitting을 false로 복원
      if (mounted) {
        state = AsyncValue.data(previousState.copyWith(isSubmitting: false));
      }
    }
  }
}

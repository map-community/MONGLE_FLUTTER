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

  // Notifier가 생성될 때, 초기 상태를 loading으로 설정하고 첫 페이지를 불러옵니다.
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
    // state.value는 현재 상태의 PaginatedComments 객체입니다.
    state = AsyncValue.data(state.value!.copyWith(replyingTo: comment));
  }

  // '답글 모드'를 해제하고 일반 댓글 모드로 돌아가는 메서드
  void exitReplyMode() {
    state = AsyncValue.data(state.value!.copyWith(replyingTo: null));
  }

  /// 첫 페이지의 댓글을 불러옵니다.
  Future<void> _fetchFirstPage() async {
    try {
      final paginatedComments = await _repository.getComments(postId: _postId);
      // 위젯이 아직 화면에 마운트되어 있을 때만 상태를 업데이트합니다.
      if (mounted) {
        state = AsyncValue.data(paginatedComments);
      }
    } catch (e, s) {
      if (mounted) {
        state = AsyncValue.error(e, s);
      }
    }
  }

  /// 다음 페이지의 댓글을 불러옵니다 (무한 스크롤).
  Future<void> fetchNextPage() async {
    // 1. 현재 상태가 데이터가 아니거나, 다음 페이지가 없거나, 이미 로딩 중이면 실행하지 않습니다.
    if (!state.hasValue || !state.value!.hasNext || state is AsyncLoading) {
      return;
    }

    final currentState = state.value!;

    try {
      // 2. Repository에 다음 페이지를 요청합니다. (cursor 사용)
      final nextPageData = await _repository.getComments(
        postId: _postId,
        cursor: currentState.nextCursor,
      );

      if (mounted) {
        // 3. 기존 댓글 목록에 새로 불러온 댓글 목록을 이어붙여 상태를 업데이트합니다.
        state = AsyncValue.data(
          currentState.copyWith(
            comments: [...currentState.comments, ...nextPageData.comments],
            nextCursor: nextPageData.nextCursor,
            hasNext: nextPageData.hasNext,
          ),
        );
      }
    } catch (e) {
      // 에러 처리는 필요에 따라 구현합니다. (예: 스낵바 표시)
      print('댓글 다음 페이지 로딩 실패: $e');
    }
  }

  Future<void> addComment(String content) async {
    // 1. 낙관적 UI: 서버 응답을 기다리지 않고 UI 상태를 즉시 업데이트
    final newComment = Comment(
      commentId: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      author: mockCurrentUser, // ✨
      createdAt: DateTime.now(),
    );

    final previousState = state.valueOrNull;
    if (previousState != null) {
      state = AsyncValue.data(
        previousState.copyWith(
          comments: [newComment, ...previousState.comments],
        ),
      );
    }

    // 2. 실제 API(Repository) 호출
    try {
      await _repository.addComment(
        postId: _postId,
        content: content,
        author: mockCurrentUser, // ✨ 목업 사용
      ); // ✨

      // 성공 시, 서버로부터 받은 실제 데이터로 상태를 다시 업데이트하거나, 목록을 새로고침할 수 있습니다.
      // 지금은 Fake Repository이므로 첫 페이지를 다시 불러와서 동기화합니다.
      _fetchFirstPage();
    } catch (e) {
      // 실패 시, 이전 상태로 되돌립니다.
      if (previousState != null) state = AsyncValue.data(previousState);
    }
  }

  Future<void> addReply(String parentCommentId, String content) async {
    // 1. 낙관적 UI
    final newReply = Comment(
      commentId: 'temp_reply_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      author: mockCurrentUser, // ✨
      createdAt: DateTime.now(),
    );

    final previousState = state.valueOrNull;
    if (previousState != null) {
      final updatedComments = previousState.comments.map((comment) {
        if (comment.commentId == parentCommentId) {
          return comment.copyWith(replies: [...comment.replies, newReply]);
        }
        return comment;
      }).toList();
      state = AsyncValue.data(
        previousState.copyWith(comments: updatedComments),
      );
    }

    // 2. 실제 API(Repository) 호출
    try {
      await _repository.addReply(
        parentCommentId: parentCommentId,
        content: content,
        author: mockCurrentUser, // ✨ 목업 사용
      ); // ✨
      _fetchFirstPage(); // 상태 동기화
    } catch (e) {
      if (previousState != null) state = AsyncValue.data(previousState);
    }
  }
}

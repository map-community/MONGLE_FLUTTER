import 'package:mongle_flutter/features/community/data/repositories/mock_comment_data.dart';
import 'package:mongle_flutter/features/community/domain/entities/author.dart';
import 'package:mongle_flutter/features/community/domain/entities/comment.dart';
import 'package:mongle_flutter/features/community/domain/entities/paginated_comments.dart';
import 'package:mongle_flutter/features/community/domain/repositories/comment_repository.dart';

class FakeCommentRepositoryImpl implements CommentRepository {
  // 메모리 내 가짜 데이터베이스 역할을 합니다.
  final Map<String, List<Comment>> _db = mockCommentsData;
  static const int _pageSize = 15; // 한 페이지에 보여줄 댓글 수

  @override
  Future<PaginatedComments> getComments({
    required String postId,
    String? cursor,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000)); // 딜레이를 늘려 로딩 확인

    final allComments = _db[postId] ?? [];

    // cursor를 기반으로 현재 페이지의 시작 인덱스를 계산합니다.
    // cursor는 다음 페이지의 시작 인덱스를 의미합니다.
    final startIndex = cursor != null ? int.tryParse(cursor) ?? 0 : 0;

    // 요청한 페이지에 해당하는 댓글들을 잘라냅니다.
    final endIndex = startIndex + _pageSize;
    final commentsForPage = allComments.sublist(
      startIndex,
      endIndex > allComments.length ? allComments.length : endIndex,
    );

    // 다음 페이지가 있는지 확인합니다.
    final hasNext = endIndex < allComments.length;
    // 다음 페이지가 있다면, 다음 페이지의 시작 인덱스를 nextCursor로 설정합니다.
    final nextCursor = hasNext ? endIndex.toString() : null;

    return PaginatedComments(
      comments: commentsForPage,
      hasNext: hasNext,
      nextCursor: nextCursor,
    );
  }

  // addComment와 addReply는 UI 테스트를 위해 나중에 구현하겠습니다.
  @override
  Future<Comment> addComment({
    required String postId,
    required String content,
    required Author author,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newComment = Comment(
      commentId: 'new_comment_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      author: mockCurrentUser, // ✨ mockCurrentUser를 사용합니다.
      createdAt: DateTime.now(),
    );
    _db[postId]?.insert(0, newComment); // 목록 맨 위에 추가
    return newComment;
  }

  @override
  Future<Comment> addReply({
    required String parentCommentId,
    required String content,
    required Author author,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newReply = Comment(
      commentId: 'new_reply_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      author: mockCurrentUser, // ✨ mockCurrentUser를 사용합니다.
      createdAt: DateTime.now(),
    );

    // 모든 게시글의 댓글을 순회하며 부모 댓글을 찾습니다.
    for (var comments in _db.values) {
      for (var i = 0; i < comments.length; i++) {
        if (comments[i].commentId == parentCommentId) {
          final parentComment = comments[i];
          final updatedReplies = [...parentComment.replies, newReply];
          comments[i] = parentComment.copyWith(replies: updatedReplies);
          return newReply;
        }
      }
    }
    throw Exception('Parent comment not found');
  }
}

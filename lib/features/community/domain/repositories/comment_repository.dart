import 'package:mongle_flutter/features/community/domain/entities/author.dart';
import 'package:mongle_flutter/features/community/domain/entities/comment.dart';
import 'package:mongle_flutter/features/community/domain/entities/paginated_comments.dart';

/// '댓글' 데이터 통신을 위한 계약서(추상 클래스)입니다.
/// Domain 계층은 이 Repository 인터페이스에만 의존하며,
/// 실제 구현(가짜 데이터, 실제 API 통신)은 Data 계층에서 담당합니다.
abstract class CommentRepository {
  /// 특정 게시글(postId)에 속한 댓글 목록을 가져옵니다.
  /// [cursor]를 통해 페이지네이션을 지원합니다.
  Future<PaginatedComments> getComments({
    required String postId,
    String? cursor,
  });

  /// 특정 게시글(postId)에 새로운 댓글을 추가합니다.
  Future<void> addComment({required String postId, required String content});

  /// 특정 댓글(parentCommentId)에 새로운 대댓글을 추가합니다.
  Future<void> addReply({
    required String parentCommentId,
    required String content,
  });

  /// 특정 댓글의 대댓글을 조회합니다.
  Future<PaginatedComments> getReplies({
    required String parentCommentId,
    int size,
    String? cursor,
  });

  /// 특정 댓글(commentId)을 삭제합니다.
  Future<void> deleteComment({required String commentId});
}

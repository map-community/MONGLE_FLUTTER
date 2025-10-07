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
  Future<void> addComment({
    required String postId,
    required String content,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newComment = Comment(
      commentId: 'new_comment_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      // author 파라미터 대신 mockCurrentUser를 사용합니다.
      author: mockCurrentUser,
      createdAt: DateTime.now(),
    );
    _db[postId]?.insert(0, newComment); // 목록 맨 위에 추가
    // 반환값이 없으므로 return 문을 삭제합니다.
  }

  @override
  Future<void> addReply({
    required String parentCommentId,
    required String content,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newReply = Comment(
      commentId: 'new_reply_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      // author 파라미터 대신 mockCurrentUser를 사용합니다.
      author: mockCurrentUser,
      createdAt: DateTime.now(),
    );

    for (var comments in _db.values) {
      for (var i = 0; i < comments.length; i++) {
        if (comments[i].commentId == parentCommentId) {
          final parentComment = comments[i];
          final updatedReplies = [...parentComment.replies, newReply];
          comments[i] = parentComment.copyWith(replies: updatedReplies);
          // 반환값이 없으므로 return 문을 삭제합니다.
          return;
        }
      }
    }
    throw Exception('Parent comment not found');
  }

  // 👇 이 메서드를 추가해주세요.
  @override
  Future<PaginatedComments> getReplies({
    required String parentCommentId,
    int size = 3, // 정책에 맞게 기본값을 3으로 설정
    String? cursor,
  }) async {
    // 실제 API 호출처럼 딜레이를 줍니다.
    await Future.delayed(const Duration(milliseconds: 300));

    // 1. DB를 모두 뒤져서 부모 댓글을 찾고, 해당 댓글의 대댓글 목록을 가져옵니다.
    List<Comment> allReplies = [];
    for (var commentsInPost in _db.values) {
      for (var parentComment in commentsInPost) {
        if (parentComment.commentId == parentCommentId) {
          allReplies = parentComment.replies;
          break;
        }
      }
      if (allReplies.isNotEmpty) break;
    }

    // 대댓글이 없으면 빈 결과를 반환합니다.
    if (allReplies.isEmpty) {
      return const PaginatedComments(
        comments: [],
        hasNext: false,
        nextCursor: null,
      );
    }

    // 2. 커서를 기반으로 페이지네이션 로직을 수행합니다.
    final startIndex = cursor != null ? int.tryParse(cursor) ?? 0 : 0;
    final endIndex = startIndex + size;

    final repliesForPage = allReplies.sublist(
      startIndex,
      endIndex > allReplies.length ? allReplies.length : endIndex,
    );

    // 3. 다음 페이지 존재 여부와 다음 커서 값을 계산합니다.
    final hasNext = endIndex < allReplies.length;
    final nextCursor = hasNext ? endIndex.toString() : null;

    // 4. 페이지네이션된 결과를 PaginatedComments 객체에 담아 반환합니다.
    return PaginatedComments(
      comments: repliesForPage,
      hasNext: hasNext,
      nextCursor: nextCursor,
    );
  }

  @override
  Future<void> deleteComment({required String commentId}) async {
    // 실제 API 호출처럼 0.3초 딜레이를 줍니다.
    await Future.delayed(const Duration(milliseconds: 300));

    // 메모리 DB를 순회하며 삭제할 댓글(또는 대댓글)을 찾습니다.
    for (final postId in _db.keys) {
      final comments = _db[postId]!;
      for (var i = 0; i < comments.length; i++) {
        // 1. 일반 댓글 목록에서 찾기
        if (comments[i].commentId == commentId) {
          // isDeleted 플래그를 true로 설정하여 '삭제된 상태'로 만듭니다.
          comments[i] = comments[i].copyWith(isDeleted: true);
          print('🗑️ [FakeRepo] 댓글 삭제됨: $commentId');
          return; // 찾았으므로 함수 종료
        }

        // 2. 대댓글 목록에서 찾기
        final replies = comments[i].replies;
        for (var j = 0; j < replies.length; j++) {
          if (replies[j].commentId == commentId) {
            replies[j] = replies[j].copyWith(isDeleted: true);
            print('🗑️ [FakeRepo] 대댓글 삭제됨: $commentId');
            return; // 찾았으므로 함수 종료
          }
        }
      }
    }
  }
}

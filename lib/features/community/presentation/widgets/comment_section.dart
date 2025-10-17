import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:mongle_flutter/features/community/domain/entities/comment.dart';
import 'package:mongle_flutter/features/community/domain/entities/paginated_comments.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/comment_item.dart';
import 'package:mongle_flutter/features/community/providers/comment_providers.dart';
import 'package:mongle_flutter/features/community/providers/reply_providers.dart';

class CommentSection extends ConsumerWidget {
  final String postId;
  const CommentSection({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(commentProvider(postId));

    return state.when(
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (err, stack) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Center(child: Text('댓글을 불러올 수 없습니다.')),
        ),
      ),
      data: (paginatedComments) {
        final comments = paginatedComments.comments;
        final replyingToComment = paginatedComments.replyingTo;

        if (comments.isEmpty) {
          return SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🆕 헤더 추가
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: const Text(
                    '댓글',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                // 기존 빈 상태 메시지
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '첫 번째 댓글을 남겨보세요!',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // ListView 대신 SliverList를 반환합니다.
        return SliverList.builder(
          // itemCount에 1을 추가 (헤더 자리)
          itemCount: 1 + comments.length + (paginatedComments.hasNext ? 1 : 0),
          itemBuilder: (context, index) {
            // 첫 번째 아이템은 헤더
            if (index == 0) {
              return Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: const Text(
                  '댓글',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              );
            }

            // 로딩 인디케이터 조건 변경
            if (index == comments.length + 1) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            // 실제 댓글 index 계산 (헤더 때문에 -1)
            final comment = comments[index - 1];

            return _CommentWithReplies(
              postId: postId,
              comment: comment,
              replyingToCommentId: paginatedComments.replyingTo?.commentId,
            );
          },
        );
      },
    );
  }

  // 댓글 입력창은 화면의 다른 부분(예: BottomAppBar)에 위치시키는 것이 더 자연스럽습니다.
  // 우선은 여기서 제외하고 스크롤 로직에 집중합니다.
}

/// 부모 댓글과 그에 속한 대댓글 섹션을 함께 묶어서 관리하는 내부 위젯
class _CommentWithReplies extends ConsumerWidget {
  final String postId;
  final Comment comment;
  final String? replyingToCommentId;

  const _CommentWithReplies({
    required this.postId,
    required this.comment,
    this.replyingToCommentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHighlighted = replyingToCommentId == comment.commentId;

    return Column(
      children: [
        // 1. 부모 댓글 그리기
        CommentItem(
          postId: postId,
          comment: comment,
          isHighlighted: isHighlighted,
        ),
        // 2. 이 댓글이 대댓글을 가지고 있다면, 대댓글 섹션 그리기
        if (comment.hasReplies)
          _RepliesSection(
            postId: postId,
            parentCommentId: comment.commentId,
            replyingToCommentId: replyingToCommentId,
          ),
        // 3. 각 댓글 그룹 아래에 구분선 추가
        Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
      ],
    );
  }
}

/// 대댓글 데이터를 불러와 UI를 그리는 역할만 하는 위젯
class _RepliesSection extends ConsumerWidget {
  final String postId;
  final String parentCommentId;
  final String? replyingToCommentId;

  const _RepliesSection({
    required this.postId,
    required this.parentCommentId,
    this.replyingToCommentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repliesState = ref.watch(repliesProvider(parentCommentId));

    return repliesState.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 50.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (e, s) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 50.0),
        child: const Text('대댓글을 불러올 수 없습니다.'),
      ),
      data: (data) {
        return Padding(
          padding: const EdgeInsets.only(left: 0), // 내부에서 들여쓰기 관리
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...data.replies.map(
                (reply) => CommentItem(
                  postId: postId,
                  comment: reply,
                  isReply: true,
                  parentCommentId: parentCommentId,
                  isHighlighted: replyingToCommentId == reply.commentId,
                ),
              ),
              if (data.hasNext)
                Padding(
                  padding: const EdgeInsets.only(left: 50.0, right: 45.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          height: 1, // 선의 높이 (영향 거의 없음)
                          thickness: 1, // 선의 두께
                          color: Colors.grey.shade300,
                        ),
                      ),
                      const SizedBox(width: 8),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade600,
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: data.isLoadingMore
                              ? null
                              : () => ref
                                    .read(
                                      repliesProvider(parentCommentId).notifier,
                                    )
                                    .fetchMoreReplies(),
                          child: data.isLoadingMore
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('대댓글 더보기'),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

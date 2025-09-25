import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/community/domain/entities/paginated_comments.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/comment_item.dart';
import 'package:mongle_flutter/features/community/providers/comment_providers.dart';

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
        if (comments.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: Center(child: Text('첫 번째 댓글을 남겨보세요!')),
            ),
          );
        }

        // ✨ ListView 대신 SliverList를 반환합니다.
        return SliverList.builder(
          itemCount: comments.length + (paginatedComments.hasNext ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == comments.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final comment = comments[index];
            // CommentItem과 대댓글 로직은 Column으로 감싸서 하나의 아이템으로 만듭니다.
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  CommentItem(comment: comment),
                  ...comment.replies.map(
                    (reply) => CommentItem(comment: reply, isReply: true),
                  ),
                  const Divider(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 댓글 입력창은 화면의 다른 부분(예: BottomAppBar)에 위치시키는 것이 더 자연스럽습니다.
  // 우선은 여기서 제외하고 스크롤 로직에 집중합니다.
}

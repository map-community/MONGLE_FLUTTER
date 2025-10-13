import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/common/widgets/more_options_menu.dart';
import 'package:mongle_flutter/features/community/domain/entities/author.dart';
import 'package:mongle_flutter/features/community/domain/entities/comment.dart';
import 'package:mongle_flutter/features/community/domain/entities/reaction_models.dart';
import 'package:mongle_flutter/features/community/domain/entities/report_models.dart';
import 'package:mongle_flutter/features/community/domain/repositories/report_repository.dart';
import 'package:mongle_flutter/features/community/providers/block_providers.dart';
import 'package:mongle_flutter/features/community/providers/comment_providers.dart';
import 'package:mongle_flutter/features/community/providers/reply_providers.dart';
import 'package:mongle_flutter/features/community/providers/report_providers.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentItem extends ConsumerStatefulWidget {
  final String postId;
  final Comment comment;
  final bool isReply;
  final bool isHighlighted;
  final String? parentCommentId;

  const CommentItem({
    super.key,
    required this.postId,
    required this.comment,
    this.isReply = false,
    this.isHighlighted = false,
    this.parentCommentId,
  });

  @override
  ConsumerState<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends ConsumerState<CommentItem> {
  @override
  Widget build(BuildContext context) {
    if (widget.comment.isDeleted) {
      return _buildDeletedComment();
    }

    final backgroundColor = widget.isHighlighted
        ? Theme.of(context).primaryColor.withOpacity(0.05)
        : Colors.transparent;

    return Container(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCommentHeader(context),

            Row(
              children: [
                if (widget.isReply)
                  const SizedBox(width: 50), // 프로필사진(36) + 간격(14) 만큼 들여쓰기
                Expanded(
                  child: Padding(
                    // 댓글 내용의 좌우 패딩을 유지합니다.
                    padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                    child: Text(
                      widget.comment.content,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                if (widget.isReply) const SizedBox(width: 50),
                Expanded(child: _buildActionBar(context, ref)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.isReply)
          const SizedBox(
            width: 40,
            child: Icon(
              Icons.subdirectory_arrow_right,
              color: Colors.grey,
              size: 20,
            ),
          ),
        CircleAvatar(
          radius: 18,
          backgroundImage: widget.comment.author.profileImageUrl != null
              ? NetworkImage(widget.comment.author.profileImageUrl!)
              : null,
          child: widget.comment.author.profileImageUrl == null
              ? const Icon(Icons.person, size: 18)
              : null,
        ),
        const SizedBox(width: 12),
        Text(
          widget.comment.author.nickname,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(width: 8),
        Text(
          timeago.format(widget.comment.createdAt.toLocal(), locale: 'ko'),
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const Spacer(),
        MoreOptionsMenu(
          contentId: widget.comment.commentId,
          contentType: ReportContentType.COMMENT,
          author: widget.comment.author,
          isAuthor: widget.comment.isAuthor,
          onDelete: () {
            // 삭제 확인 다이얼로그는 MoreOptionsMenu에서 처리하므로,
            // 여기서는 실제 삭제 로직만 실행합니다.
            ref
                .read(commentProvider(widget.postId).notifier)
                .deleteComment(
                  widget.comment.commentId,
                  widget.comment.author.id!,
                );
          },
        ),
      ],
    );
  }

  Widget _buildActionBar(BuildContext context, WidgetRef ref) {
    final myReaction = widget.comment.myReaction;

    return Row(
      children: [
        _buildActionButton(
          icon: myReaction == ReactionType.LIKE
              ? Icons.thumb_up
              : Icons.thumb_up_outlined,
          count: widget.comment.likeCount,
          color: myReaction == ReactionType.LIKE
              ? Theme.of(context).primaryColor
              : Colors.grey.shade700,
          onTap: () {
            if (widget.isReply && widget.parentCommentId != null) {
              ref
                  .read(repliesProvider(widget.parentCommentId!).notifier)
                  .like(widget.comment.commentId);
            } else {
              ref
                  .read(commentProvider(widget.postId).notifier)
                  .like(widget.comment.commentId);
            }
          },
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: myReaction == ReactionType.DISLIKE
              ? Icons.thumb_down
              : Icons.thumb_down_outlined,
          count: widget.comment.dislikeCount,
          color: myReaction == ReactionType.DISLIKE
              ? Colors.grey.shade800
              : Colors.grey.shade700,
          onTap: () {
            if (widget.isReply && widget.parentCommentId != null) {
              ref
                  .read(repliesProvider(widget.parentCommentId!).notifier)
                  .dislike(widget.comment.commentId);
            } else {
              ref
                  .read(commentProvider(widget.postId).notifier)
                  .dislike(widget.comment.commentId);
            }
          },
        ),
        const SizedBox(width: 8),
        if (!widget.isReply) ...[
          _buildActionButton(
            icon: Icons.reply_outlined,
            text: '답글',
            color: Colors.grey.shade700,
            onTap: () {
              Scrollable.ensureVisible(
                context,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: 0.2,
              );
              ref
                  .read(commentProvider(widget.postId).notifier)
                  .enterReplyMode(widget.comment);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    int? count,
    String? text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            if (count != null)
              Text(
                count.toString(),
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (text != null)
              Text(
                text,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeletedComment() {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.isReply)
            const SizedBox(
              width: 40.0,
              child: Icon(
                Icons.subdirectory_arrow_right,
                color: Colors.grey,
                size: 20,
              ),
            ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.delete_outline,
              color: Colors.grey.shade500,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '삭제된 댓글입니다.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final GlobalKey _menuKey = GlobalKey();

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
            // 4. 액션 툴바도 독립적으로 배치됩니다.
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
        // 1. 대댓글 아이콘을 헤더로 이동
        if (widget.isReply)
          const SizedBox(
            width: 40,
            child: Icon(
              Icons.subdirectory_arrow_right,
              color: Colors.grey,
              size: 20,
            ),
          ),

        // 2. CircleAvatar를 Row의 첫 번째 요소로 추가
        CircleAvatar(
          radius: 18,
          backgroundImage: widget.comment.author.profileImageUrl != null
              ? NetworkImage(widget.comment.author.profileImageUrl!)
              : null,
          child: widget.comment.author.profileImageUrl == null
              ? const Icon(Icons.person, size: 18)
              : null,
        ),

        // 3. 사진과 닉네임 사이의 간격 추가
        const SizedBox(width: 12),

        Text(
          widget.comment.author.nickname,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(width: 8),
        Text(
          timeago.format(widget.comment.createdAt, locale: 'ko'),
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const Spacer(),
        _buildMoreMenu(context),
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
            if (widget.isReply) {
              // 대댓글의 경우 RepliesNotifier를 호출
              ref
                  .read(repliesProvider(widget.parentCommentId!).notifier)
                  .like(widget.comment.commentId);
            } else {
              // 일반 댓글의 경우 CommentNotifier를 호출
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
            if (widget.isReply) {
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
    required Color color, // color를 필수로 받도록 변경
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

  void _showBlockConfirmationDialog(BuildContext context, Author author) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('사용자 차단'),
          content: Text(
            "'${author.nickname}'님을 차단하시겠습니까?\n차단한 사용자의 모든 게시물과 댓글이 더 이상 보이지 않게 됩니다.",
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('차단', style: TextStyle(color: Colors.red)),
              onPressed: () {
                // ✅ [수정] author.id가 null이 아닌지 확인하는 안전장치 추가
                final authorId = author.id;
                if (authorId != null) {
                  ref.read(blockedUsersProvider.notifier).blockUser(authorId);
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${author.nickname}님을 차단했습니다.'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildMoreMenu(BuildContext context) {
    final isAuthor = widget.comment.isAuthor;

    return PopupMenuButton<String>(
      key: _menuKey,
      icon: Icon(Icons.more_vert, size: 20, color: Colors.grey.shade600),
      tooltip: '더보기',
      onSelected: (value) {
        if (value == 'report') {
          Future.delayed(
            const Duration(milliseconds: 100),
            () => _showReportReasonMenu(context),
          );
        } else if (value == 'block') {
          _showBlockConfirmationDialog(context, widget.comment.author);
        } else if (value == 'delete') {
          // ✨ 3. [추가] 삭제 선택 시 동작
          _showDeleteConfirmationDialog(context, widget.comment);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(value: 'report', child: Text('신고하기')),
        const PopupMenuItem<String>(
          value: 'block',
          child: Text('이 사용자 차단하기'),
        ), // ✨ 4. [추가] 내가 쓴 댓글일 경우에만 '삭제하기' 메뉴를 보여줌
        if (isAuthor) const PopupMenuDivider(), // 구분선
        if (isAuthor)
          const PopupMenuItem<String>(
            value: 'delete',
            child: Text('삭제하기', style: TextStyle(color: Colors.red)),
          ),
      ],
    );
  }

  void _showReportReasonMenu(BuildContext context) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RenderBox renderBox =
        _menuKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);

    showMenu<ReportReason>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, size.width, size.height),
        Offset.zero & overlay.size,
      ),
      items: ReportReason.values.map((reason) {
        return PopupMenuItem<ReportReason>(
          value: reason,
          child: Text(reason.korean),
        );
      }).toList(),
    ).then((selectedReason) {
      if (selectedReason != null) {
        ref
            .read(reportRepositoryProvider)
            .reportContent(
              contentId: widget.comment.commentId,
              contentType: ReportContentType.COMMENT,
              reason: selectedReason,
            );
        ref
            .read(reportedContentProvider.notifier)
            .addReportedContent(
              contentId: widget.comment.commentId,
              contentType: ReportContentType.COMMENT,
            );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('신고가 접수되었습니다.')));
      }
    });
  }

  // ✨ 1. [추가] 삭제 확인 대화상자를 띄우는 메서드
  void _showDeleteConfirmationDialog(BuildContext context, Comment comment) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('댓글 삭제'),
          content: const Text('정말로 이 댓글을 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // 대화상자 닫기
              },
            ),
            TextButton(
              child: const Text('삭제', style: TextStyle(color: Colors.red)),
              onPressed: () {
                // Notifier의 deleteComment 메서드 호출
                ref
                    .read(commentProvider(widget.postId).notifier)
                    .deleteComment(comment.commentId, comment.author.id!);
                Navigator.of(dialogContext).pop(); // 대화상자 닫기
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDeletedComment() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
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
          const Expanded(
            child: Text(
              '삭제된 댓글입니다.',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}

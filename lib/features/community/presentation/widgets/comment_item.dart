import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/community/domain/entities/author.dart';
import 'package:mongle_flutter/features/community/domain/entities/comment.dart';
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

  const CommentItem({
    super.key,
    required this.postId,
    required this.comment,
    this.isReply = false,
    this.isHighlighted = false,
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

            if (widget.comment.hasReplies && !widget.isReply)
              _buildRepliesSection(),

            // 4. 액션 툴바도 독립적으로 배치됩니다.
            Row(
              children: [
                if (widget.isReply) const SizedBox(width: 50),
                Expanded(child: _buildActionBar(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 👇 [신규] 대댓글 섹션을 그리는 위젯 메서드를 새로 추가합니다.
  Widget _buildRepliesSection() {
    // 새로 만든 repliesProvider를 사용하여 이 댓글의 대댓글 상태를 감시합니다.
    final repliesState = ref.watch(repliesProvider(widget.comment.commentId));

    return repliesState.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (e, s) {
        print('대댓글 로딩 에러: $e');
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('대댓글을 불러올 수 없습니다.'),
        );
      },
      data: (data) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 불러온 대댓글 목록을 CommentItem 위젯을 재사용하여 그립니다.
            ...data.replies.map(
              (reply) => CommentItem(
                postId: widget.postId,
                comment: reply,
                isReply: true, // isReply 플래그를 true로 전달
              ),
            ),
            // 더 불러올 대댓글이 있으면 '더보기' 버튼을 표시합니다.
            if (data.hasNext)
              TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                onPressed: data.isLoadingMore
                    ? null // 로딩 중에는 버튼 비활성화
                    : () {
                        // 버튼을 누르면 다음 페이지를 불러오는 함수를 호출합니다.
                        ref
                            .read(
                              repliesProvider(
                                widget.comment.commentId,
                              ).notifier,
                            )
                            .fetchMoreReplies();
                      },
                child: data.isLoadingMore
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('대댓글 더보기'),
              ),
          ],
        );
      },
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

  Widget _buildActionBar(BuildContext context) {
    return Row(
      children: [
        _buildActionButton(
          icon: Icons.thumb_up_outlined,
          count: widget.comment.likeCount,
          onTap: () {},
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.thumb_down_outlined,
          count: widget.comment.dislikeCount,
          onTap: () {},
        ),
        const SizedBox(width: 8),
        if (!widget.isReply) ...[
          _buildActionButton(
            icon: Icons.reply_outlined,
            text: '답글',
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
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade700),
            const SizedBox(width: 4),
            if (count != null)
              Text(
                count.toString(),
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (text != null)
              Text(
                text,
                style: TextStyle(
                  color: Colors.grey.shade800,
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
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(value: 'report', child: Text('신고하기')),
        const PopupMenuItem<String>(value: 'block', child: Text('이 사용자 차단하기')),
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

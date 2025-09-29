import 'package:flutter/material.dart';
import 'package:mongle_flutter/features/community/domain/entities/author.dart';
import 'package:mongle_flutter/features/community/domain/entities/comment.dart';
import 'package:mongle_flutter/features/community/domain/entities/report_models.dart';
import 'package:mongle_flutter/features/community/providers/comment_providers.dart';
import 'package:mongle_flutter/features/community/providers/block_providers.dart';
import 'package:mongle_flutter/features/community/providers/report_providers.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommentItem extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    if (comment.isDeleted) {
      return _buildDeletedComment();
    }

    final backgroundColor = isHighlighted
        ? Theme.of(context).primaryColor.withOpacity(0.05)
        : Colors.transparent;

    return Container(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✨ 1. 대댓글일 경우 'ㄴ' 아이콘과 공간을 추가합니다.
            if (isReply)
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
              backgroundImage: comment.author.profileImageUrl != null
                  ? NetworkImage(comment.author.profileImageUrl!)
                  : null,
              child: comment.author.profileImageUrl == null
                  ? const Icon(Icons.person, size: 18)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCommentHeader(context, ref),
                  const SizedBox(height: 4),
                  Text(
                    comment.content,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 8),
                  // ✨ 2. 좋아요, 싫어요, 대댓글 버튼을 위한 액션 바를 추가합니다.
                  _buildActionBar(context, ref),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 댓글 상단 (작성자 정보, 시간, 더보기 메뉴)
  Widget _buildCommentHeader(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Text(
          comment.author.nickname,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(width: 8),
        Text(
          timeago.format(comment.createdAt, locale: 'ko'),
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const Spacer(), // 오른쪽에 메뉴 버튼을 밀어내기 위한 Spacer
        // ✨ 3. 신고, 차단 기능이 담긴 더보기 메뉴를 추가합니다.
        _buildMoreMenu(context, ref),
      ],
    );
  }

  // 댓글 하단 액션 바 (좋아요, 싫어요, 대댓글)
  Widget _buildActionBar(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        _buildActionButton(
          icon: Icons.thumb_up_outlined,
          count: comment.likeCount,
          onTap: () {},
        ),

        const SizedBox(width: 8),

        _buildActionButton(
          icon: Icons.thumb_down_outlined,
          count: comment.dislikeCount,
          onTap: () {},
        ),

        const SizedBox(width: 8),

        if (!isReply) ...[
          _buildActionButton(
            icon: Icons.reply_outlined,
            text: '답글',
            onTap: () {
              Scrollable.ensureVisible(
                context,
                duration: const Duration(milliseconds: 200), // 스크롤 애니메이션 시간
                curve: Curves.easeInOut, // 부드러운 스크롤 효과
                alignment: 0.2, // 화면 상단에서 20% 위치에 오도록 정렬
              );

              ref
                  .read(commentProvider(postId).notifier)
                  .enterReplyMode(comment);
            },
          ),
        ],
      ],
    );
  }

  // 액션 바에 사용될 재사용 가능한 버튼 위젯
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

  /// 사용자 차단 확인 다이얼로그를 표시하는 함수
  void _showBlockConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    Author author,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('사용자 차단'),
          content: Text(
            "'${author.nickname}'님을 차단하시겠습니까?\n차단한 사용자의 모든 게시물과 댓글이 더 이상 보이지 않게 됩니다.",
          ),
          actions: <Widget>[
            // '취소' 버튼
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                // 다이얼로그를 닫습니다.
                Navigator.of(dialogContext).pop();
              },
            ),
            // '차단' 버튼
            TextButton(
              child: const Text(
                '차단',
                style: TextStyle(color: Colors.red), // 위험한 동작임을 알려주는 색상
              ),
              onPressed: () {
                // 1. 차단 로직을 실행합니다.
                ref.read(blockedUsersProvider.notifier).blockUser(author.id);

                // 2. 다이얼로그를 닫습니다.
                Navigator.of(dialogContext).pop();

                // 3. 작업 완료 피드백을 SnackBar로 표시합니다.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${author.nickname}님을 차단했습니다.'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  /// 콘텐츠 신고 다이얼로그를 표시하는 함수
  void _showReportDialog(
    BuildContext context,
    WidgetRef ref,
    String contentId,
    ReportContentType contentType,
  ) {
    ReportReason? selectedReason; // 사용자가 선택한 신고 사유를 저장할 변수
    final descriptionController = TextEditingController(); // 상세 내용을 위한 컨트롤러

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // StatefulBuilder를 사용해야 다이얼로그 내부에서 상태(선택된 사유) 변경이 가능합니다.
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('콘텐츠 신고'),
              content: SingleChildScrollView(
                // 내용이 길어질 수 있으므로 스크롤 가능하게
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('신고 사유를 선택해주세요.'),
                    // ReportReason Enum의 모든 값을 가져와 라디오 버튼으로 만듭니다.
                    ...ReportReason.values.map((reason) {
                      return RadioListTile<ReportReason>(
                        title: Text(reason.korean), // 간단하게 Enum 이름으로 표시
                        value: reason,
                        groupValue: selectedReason,
                        onChanged: (value) {
                          setState(() {
                            // 다이얼로그 내부 UI만 새로고침
                            selectedReason = value;
                          });
                        },
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                    const Text('상세 내용 (선택 사항)'),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '문제 상황을 더 자세히 알려주세요.',
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('취소'),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                TextButton(
                  // 사유를 선택해야만 제출 버튼이 활성화됩니다.
                  onPressed: selectedReason == null
                      ? null
                      : () {
                          // 1. 백엔드(가짜 서버)에 신고 내용 전송
                          ref
                              .read(reportRepositoryProvider)
                              .reportContent(
                                contentId: contentId,
                                contentType: contentType,
                                reason: selectedReason!,
                                description: descriptionController.text,
                              );

                          // 2. '즉시 숨김'을 위해 로컬 상태 업데이트
                          ref
                              .read(reportedContentProvider.notifier)
                              .addReportedContent(
                                contentId: contentId,
                                contentType: contentType,
                              );

                          Navigator.of(dialogContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('신고가 접수되었습니다.')),
                          );
                        },
                  child: const Text('제출'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // '더보기' 팝업 메뉴
  Widget _buildMoreMenu(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 32,
      height: 32,
      child: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, size: 20, color: Colors.grey.shade600),
        tooltip: '더보기',
        onSelected: (value) {
          if (value == 'report') {
            _showReportDialog(
              context,
              ref,
              comment.commentId,
              ReportContentType.COMMENT,
            );
          } else if (value == 'block') {
            _showBlockConfirmationDialog(context, ref, comment.author);
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'report',
            child: Row(
              children: [
                Icon(
                  Icons.report_outlined,
                  size: 20,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 8),
                const Text('신고하기'),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'block',
            child: Row(
              children: [
                Icon(Icons.block, size: 20, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                const Text('이 사용자 차단하기'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 삭제된 댓글 UI
  Widget _buildDeletedComment() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          if (isReply)
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

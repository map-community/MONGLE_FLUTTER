import 'package:flutter/material.dart';
import 'package:mongle_flutter/features/community/domain/entities/comment.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentItem extends StatelessWidget {
  final Comment comment;
  final bool isReply;

  const CommentItem({super.key, required this.comment, this.isReply = false});

  @override
  Widget build(BuildContext context) {
    if (comment.isDeleted) {
      return _buildDeletedComment();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                _buildCommentHeader(context),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 8),
                // ✨ 2. 좋아요, 싫어요, 대댓글 버튼을 위한 액션 바를 추가합니다.
                _buildActionBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 댓글 상단 (작성자 정보, 시간, 더보기 메뉴)
  Widget _buildCommentHeader(BuildContext context) {
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
        _buildMoreMenu(context),
      ],
    );
  }

  // 댓글 하단 액션 바 (좋아요, 싫어요, 대댓글)
  Widget _buildActionBar() {
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
            onTap: () {},
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

  // '더보기' 팝업 메뉴
  Widget _buildMoreMenu(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, size: 20, color: Colors.grey.shade600),
        tooltip: '더보기',
        onSelected: (value) {
          if (value == 'report') {
            print('신고 처리 로직 실행');
          } else if (value == 'block') {
            print('사용자 차단 로직 실행');
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
      padding: EdgeInsets.only(
        left: isReply ? 40.0 : 0.0,
        top: 8.0,
        bottom: 8.0,
      ),
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
          const Text(
            '삭제된 댓글입니다.',
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

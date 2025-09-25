import 'package:flutter/material.dart';
import 'package:mongle_flutter/features/community/domain/entities/comment.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentItem extends StatelessWidget {
  final Comment comment;
  final bool isReply; // 대댓글 여부

  const CommentItem({super.key, required this.comment, this.isReply = false});

  @override
  Widget build(BuildContext context) {
    // isDeleted가 true이면 "삭제된 댓글입니다" 메시지를 표시합니다.
    if (comment.isDeleted) {
      return Padding(
        padding: EdgeInsets.only(
          left: isReply ? 40.0 : 0.0,
          top: 8.0,
          bottom: 8.0,
        ),
        child: const Text(
          '삭제된 댓글입니다.',
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        ),
      );
    }

    return Padding(
      // 대댓글일 경우 왼쪽에 40만큼의 패딩을 주어 들여쓰기 효과를 냅니다.
      padding: EdgeInsets.only(
        left: isReply ? 40.0 : 0.0,
        top: 8.0,
        bottom: 8.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                Row(
                  children: [
                    Text(
                      comment.author.nickname,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeago.format(comment.createdAt, locale: 'ko'),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

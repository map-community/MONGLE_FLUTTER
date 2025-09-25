import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/community/domain/entities/comment.dart';
import 'package:mongle_flutter/features/community/providers/comment_providers.dart';

class CommentInputField extends ConsumerWidget {
  final String postId;
  const CommentInputField({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentStateAsync = ref.watch(commentProvider(postId));
    final replyingToComment = commentStateAsync.valueOrNull?.replyingTo;

    // SafeArea는 그대로 유지하여 시스템 네비게이션 바를 침범하지 않도록 합니다.
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, -2),
              blurRadius: 5.0,
            ),
          ],
        ),
        padding: EdgeInsets.only(
          // 키보드가 올라올 때 시스템이 추가하는 패딩을 감지하여 적용합니다.
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Column이 내용물의 높이만큼만 차지하도록 설정
          children: [
            if (replyingToComment != null)
              _buildReplyingToBar(context, ref, replyingToComment),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      // 텍스트 스타일을 지정하여 글자 크기를 줄입니다.
                      style: const TextStyle(fontSize: 14),
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: replyingToComment == null
                            ? '댓글을 입력하세요.'
                            : '답글을 입력하세요.',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      // TODO: 댓글 등록 로직 구현
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // '답글 대상'을 표시하는 별도의 위젯 메서드를 만듭니다.
  Widget _buildReplyingToBar(
    BuildContext context,
    WidgetRef ref,
    Comment replyingToComment,
  ) {
    final notifier = ref.read(commentProvider(postId).notifier);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
      color: Theme.of(context).primaryColor.withOpacity(0.05),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '@${replyingToComment.author.nickname}님에게 답글 남기는 중...',
              style: TextStyle(
                color: Theme.of(context).primaryColorDark,
                fontSize: 13,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 16, color: Colors.grey.shade700),
            onPressed: () => notifier.exitReplyMode(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

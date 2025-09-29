import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/core/services/profanity_filter_service.dart';
import 'package:mongle_flutter/features/community/domain/entities/comment.dart';
import 'package:mongle_flutter/features/community/domain/entities/paginated_comments.dart';
import 'package:mongle_flutter/features/community/providers/comment_providers.dart';

class CommentInputField extends ConsumerStatefulWidget {
  final String postId;
  const CommentInputField({super.key, required this.postId});

  @override
  ConsumerState<CommentInputField> createState() => _CommentInputFieldState();
}

class _CommentInputFieldState extends ConsumerState<CommentInputField> {
  late final FocusNode _focusNode;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    // FocusNode는 반드시 dispose 해주어야 메모리 누수를 막을 수 있습니다.
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✨ 4. ref.listen을 사용하여 상태 변화를 감지하고, 포커스를 요청합니다.
    ref.listen(commentProvider(widget.postId), (previous, next) {
      // is-a 검사를 통해 next.value가 null이 아님을 확인합니다.
      if (next is AsyncData<PaginatedComments>) {
        final wasReplying =
            previous is AsyncData<PaginatedComments> &&
            previous.value.replyingTo != null;
        final isNowReplying = next.value.replyingTo != null;

        // '일반 모드' -> '답글 모드'로 바뀌는 순간에만 포커스를 요청합니다.
        if (!wasReplying && isNowReplying) {
          _focusNode.requestFocus();
        }
      }
    });

    final commentStateAsync = ref.watch(commentProvider(widget.postId));
    final replyingToComment = commentStateAsync.valueOrNull?.replyingTo;
    final isSubmitting =
        commentStateAsync.valueOrNull?.isSubmitting ??
        commentStateAsync.isLoading;
    final notifier = ref.read(commentProvider(widget.postId).notifier);

    // SafeArea는 그대로 유지하여 시스템 네비게이션 바를 침범하지 않도록 합니다.
    return IgnorePointer(
      ignoring: isSubmitting,
      child: Opacity(
        opacity: isSubmitting ? 0.5 : 1.0,
        child: SafeArea(
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
                  _buildReplyingToBar(context, notifier, replyingToComment),

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
                          controller: _textController, // ✨ 2. 컨트롤러 연결
                          focusNode: _focusNode, // ✨ 3. 포커스 노드 연결
                          enabled: !isSubmitting,
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
                        onPressed: isSubmitting
                            ? null
                            : () {
                                final content = _textController.text.trim();
                                if (content.isEmpty) return; // 내용이 없으면 전송 안 함

                                final filterService = ref.read(
                                  profanityFilterProvider,
                                );

                                // ✅ [수정] bool 대신 String? 타입으로 결과를 받습니다.
                                final String? foundProfanity = filterService
                                    .findFirstProfanity(content);

                                // ✅ [수정] 결과(foundProfanity)가 null이 아닌지 확인하여 분기 처리합니다.
                                if (foundProfanity != null) {
                                  // ✅ [수정] SnackBar 메시지에 발견된 단어를 포함하여 보여줍니다.
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "'${foundProfanity}'은(는) 사용할 수 없는 단어입니다.",
                                      ),
                                      backgroundColor:
                                          Colors.red, // 경고 메시지이므로 색상 강조
                                    ),
                                  );
                                  return; // 제출을 중단합니다.
                                }

                                // 답글 모드인지 확인
                                if (replyingToComment != null) {
                                  // 답글 등록 로직 호출
                                  notifier.addReply(
                                    replyingToComment.commentId,
                                    content,
                                  );
                                } else {
                                  // 일반 댓글 등록 로직 호출
                                  notifier.addComment(content);
                                }

                                // ✨ 전송 후 입력창 비우고 키보드 내리기
                                _textController.clear();
                                _focusNode.unfocus();
                              },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // '답글 대상'을 표시하는 별도의 위젯 메서드를 만듭니다.
  Widget _buildReplyingToBar(
    BuildContext context,
    CommentNotifier notifier, // ✨ notifier를 직접 전달받도록 수정
    Comment replyingToComment,
  ) {
    final notifier = ref.read(commentProvider(widget.postId).notifier);

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
            onPressed: () {
              notifier.exitReplyMode();
              _focusNode.unfocus();
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

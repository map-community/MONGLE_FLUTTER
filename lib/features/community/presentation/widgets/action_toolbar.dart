import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/community/providers/issue_grain_providers.dart';

// 1. ConsumerWidget으로 변경하여 ref를 사용할 수 있도록 합니다.
class ActionToolbar extends ConsumerWidget {
  final String postId; // 2. 어떤 게시글에 대한 액션인지 식별하기 위해 postId를 받습니다.
  const ActionToolbar({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // 3. onPressed 콜백에서 Notifier의 함수를 호출합니다.
            IconButton(
              icon: const Icon(Icons.thumb_up_outlined),
              onPressed: () {
                // ref.read를 사용해 Notifier 인스턴스에 접근하고 like() 메서드를 호출합니다.
                ref.read(issueGrainProvider(postId).notifier).like();
              },
            ),
            IconButton(
              icon: const Icon(Icons.thumb_down_outlined),
              onPressed: () {
                ref.read(issueGrainProvider(postId).notifier).dislike();
              },
            ),
            IconButton(
              icon: const Icon(Icons.comment_outlined),
              onPressed: () {},
            ),
          ],
        ),
        IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
      ],
    );
  }
}

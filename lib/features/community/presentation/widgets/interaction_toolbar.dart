// lib/features/community/presentation/widgets/interaction_toolbar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/community/domain/entities/issue_grain.dart';
import 'package:mongle_flutter/features/community/domain/entities/reaction_models.dart';
import 'package:mongle_flutter/features/community/providers/issue_grain_providers.dart';

class InteractionToolbar extends ConsumerWidget {
  final IssueGrain grain;
  final VoidCallback? onTap;

  const InteractionToolbar({super.key, required this.grain, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ⭐ grain을 포함한 파라미터로 Provider 구독
    final param = ReactionProviderParam(postId: grain.postId, grain: grain);
    final reactionState = ref.watch(reactionNotifierProvider(param));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // 조회수
          _buildStatIcon(
            context,
            icon: Icons.visibility_outlined,
            count: grain.viewCount.toString(),
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),

          // 좋아요
          _buildStatIcon(
            context,
            icon: reactionState.myReaction == ReactionType.LIKE
                ? Icons.thumb_up
                : Icons.thumb_up_outlined,
            count: reactionState.likeCount.toString(),
            color: reactionState.myReaction == ReactionType.LIKE
                ? Colors.blueAccent
                : Colors.grey.shade600,
            onTap: reactionState.isUpdating
                ? null
                : () {
                    ref.read(reactionNotifierProvider(param).notifier).like();
                  },
          ),
          const SizedBox(width: 8),

          // 싫어요
          _buildStatIcon(
            context,
            icon: reactionState.myReaction == ReactionType.DISLIKE
                ? Icons.thumb_down
                : Icons.thumb_down_outlined,
            count: reactionState.dislikeCount.toString(),
            color: Colors.grey.shade600,
            onTap: reactionState.isUpdating
                ? null
                : () {
                    ref
                        .read(reactionNotifierProvider(param).notifier)
                        .dislike();
                  },
          ),
          const SizedBox(width: 8),

          // 댓글
          _buildStatIcon(
            context,
            icon: Icons.comment_outlined,
            count: grain.commentCount.toString(),
            color: Colors.grey.shade600,
            onTap: onTap,
          ),
          const Spacer(),

          // 공유
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // TODO: 공유 기능 구현
            },
            iconSize: 20,
            color: Colors.grey.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildStatIcon(
    BuildContext context, {
    required IconData icon,
    required String count,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(
              count,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

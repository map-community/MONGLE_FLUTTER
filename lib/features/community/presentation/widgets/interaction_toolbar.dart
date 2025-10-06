import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/community/domain/entities/issue_grain.dart';
import 'package:mongle_flutter/features/community/domain/entities/reaction_models.dart';
import 'package:mongle_flutter/features/community/providers/issue_grain_providers.dart';
import 'package:mongle_flutter/features/map/presentation/providers/map_interaction_providers.dart';

class InteractionToolbar extends ConsumerWidget {
  final IssueGrain grain;
  final VoidCallback? onTap;

  const InteractionToolbar({super.key, required this.grain, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reactionNotifier = ref.read(reactionNotifierProvider(grain.postId));
    final myReaction = grain.myReaction;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // 1. 조회수 (탭 기능 없음)
          _buildStatIcon(
            context,
            icon: Icons.visibility_outlined,
            count: grain.viewCount.toString(),
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          // 2. 좋아요 (탭 기능 있음)
          _buildStatIcon(
            context,
            icon: myReaction == ReactionType.LIKE
                ? Icons
                      .thumb_up // 내가 좋아요를 눌렀다면 채워진 아이콘
                : Icons.thumb_up_outlined, // 아니라면 테두리 아이콘
            count: grain.likeCount.toString(),
            color: myReaction == ReactionType.LIKE
                ? Colors
                      .blueAccent // 내가 좋아요를 눌렀다면 파란색
                : Colors.grey.shade600,
            onTap: reactionNotifier.like, // Notifier의 like() 함수 호출
          ),
          const SizedBox(width: 8),
          // 3. 싫어요 (탭 기능 있음)
          _buildStatIcon(
            context,
            icon: myReaction == ReactionType.DISLIKE
                ? Icons
                      .thumb_down // 내가 싫어요를 눌렀다면 채워진 아이콘
                : Icons.thumb_down_outlined, // 아니라면 테두리 아이콘
            count: grain.dislikeCount.toString(),
            color: Colors.grey.shade600, // 싫어요는 항상 회색으로 유지
            onTap: reactionNotifier.dislike, // Notifier의 dislike() 함수 호출
          ),
          const SizedBox(width: 8),
          // 4. 댓글 (탭 기능 있음)
          _buildStatIcon(
            context,
            icon: Icons.comment_outlined,
            count: grain.commentCount.toString(),
            color: Colors.grey.shade600,
            onTap: onTap,
          ),
          // 5. Spacer: 남은 공간을 모두 차지하여 공유 버튼을 오른쪽 끝으로 밀어냄
          const Spacer(),
          // 6. 공유 버튼
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

  // 아이콘 + 숫자 UI를 만드는 재사용 가능한 함수
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

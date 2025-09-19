import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/community/domain/entities/issue_grain.dart';
import 'package:mongle_flutter/features/community/providers/issue_grain_providers.dart';

class InteractionToolbar extends ConsumerWidget {
  final IssueGrain grain;
  const InteractionToolbar({super.key, required this.grain});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // 1. 조회수 (탭 기능 없음)
          _buildStatIcon(
            context,
            icon: Icons.visibility_outlined,
            count: grain.viewCount.toString(),
          ),
          const SizedBox(width: 8),
          // 2. 좋아요 (탭 기능 있음)
          _buildStatIcon(
            context,
            icon: Icons.thumb_up_outlined,
            count: grain.likeCount.toString(),
            onTap: () {
              ref.read(issueGrainProvider(grain.id).notifier).like();
            },
          ),
          const SizedBox(width: 8),
          // 3. 싫어요 (탭 기능 있음)
          _buildStatIcon(
            context,
            icon: Icons.thumb_down_outlined,
            count: grain.dislikeCount.toString(),
            onTap: () {
              ref.read(issueGrainProvider(grain.id).notifier).dislike();
            },
          ),
          const SizedBox(width: 8),
          // 4. 댓글 (탭 기능 있음)
          _buildStatIcon(
            context,
            icon: Icons.comment_outlined,
            count: grain.commentCount.toString(),
            onTap: () {
              // TODO: 댓글 화면으로 이동
            },
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
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              count,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

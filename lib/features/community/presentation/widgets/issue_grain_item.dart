import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/community/domain/entities/issue_grain.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/action_toolbar.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/image_carousel.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/interaction_toolbar.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/stats_and_comments.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/user_profile_line.dart';
import 'package:mongle_flutter/features/community/providers/issue_grain_providers.dart';
import 'package:timeago/timeago.dart' as timeago;

class IssueGrainItem extends ConsumerWidget {
  final String postId;
  final bool isPreview;
  final VoidCallback? onTap;

  const IssueGrainItem({
    super.key,
    required this.postId,
    this.isPreview = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grainAsync = ref.watch(issueGrainProvider(postId));

    return grainAsync.when(
      loading: () => const SizedBox(
        height: 150, // 로딩 중 고정 높이를 주어 깜빡임 방지
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, stack) => Center(child: Text('오류: $e')),
      data: (grain) {
        // [수정] isPreview 상태에 따라 다른 build 메서드를 호출
        return InkWell(
          onTap: onTap,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: isPreview
                    ? _buildPreviewLayout(context, grain)
                    : _buildFullLayout(context, grain),
              ),
              Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
            ],
          ),
        );
      },
    );
  }

  // [신규] 미리보기 또는 목록 아이템을 위한 레이아웃
  Widget _buildPreviewLayout(BuildContext context, IssueGrain grain) {
    // 1. 가장 바깥 위젯을 Row에서 Column으로 변경합니다.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 2. '전체 보기'에서 사용하는 프로필+작성자 Row를 그대로 가져옵니다.
        Row(
          children: [
            UserProfileLine(profileImageUrl: grain.author.profileImageUrl),
            const SizedBox(width: 8),
            Expanded(child: _buildAuthorRow(grain)),
          ],
        ),
        const SizedBox(height: 8),
        // 3. 나머지 콘텐츠는 Column 아래에 순서대로 배치합니다.
        Text(
          grain.content,
          style: const TextStyle(height: 1.5),
          maxLines: 5, // 미리보기는 5줄 제한
          overflow: TextOverflow.ellipsis,
        ),
        if (grain.photoUrls.isNotEmpty) ...[
          const SizedBox(height: 12),
          ImageCarousel(imageUrls: grain.photoUrls, isPreview: true),
        ],
        InteractionToolbar(grain: grain),
      ],
    );
  }

  // [신규] 전체보기를 위한 레이아웃
  Widget _buildFullLayout(BuildContext context, IssueGrain grain) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 전체보기에서는 프로필 정보가 콘텐츠 상단에 위치
        Row(
          children: [
            UserProfileLine(profileImageUrl: grain.author.profileImageUrl),
            const SizedBox(width: 8),
            Expanded(child: _buildAuthorRow(grain)),
          ],
        ),
        const SizedBox(height: 16),
        // ▼▼▼ 텍스트 표시 부분을 위로 이동
        Text(grain.content, style: const TextStyle(height: 1.6, fontSize: 15)),
        const SizedBox(height: 16),
        // ▼▼▼ 이미지 표시 부분을 아래로 이동
        if (grain.photoUrls.isNotEmpty) ...[
          ImageCarousel(imageUrls: grain.photoUrls, isPreview: false),
          const SizedBox(height: 16),
        ],
        InteractionToolbar(grain: grain),
      ],
    );
  }

  // [신규] 중복 코드를 제거하기 위한 작성자 정보 위젯
  Widget _buildAuthorRow(IssueGrain grain) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          grain.author.nickname,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Text(
          timeago.format(grain.createdAt, locale: 'ko'),
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

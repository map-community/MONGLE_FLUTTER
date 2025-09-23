import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/community/domain/entities/issue_grain.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/image_carousel.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/interaction_toolbar.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/user_profile_line.dart';
import 'package:mongle_flutter/features/community/providers/issue_grain_providers.dart';
import 'package:timeago/timeago.dart' as timeago;

/// IssueGrainItem 위젯이 UI를 표시하는 세 가지 다른 모드를 정의합니다.
enum IssueGrainDisplayMode {
  /// 지도 위에서 탭했을 때 (사진X, 텍스트 생략)
  mapPreview,

  /// 구름 게시판 목록 (사진O, 텍스트 '더보기')
  boardPreview,

  /// 전체 내용 보기
  fullView,
}

class IssueGrainItem extends ConsumerWidget {
  final String postId;
  final VoidCallback? onTap;

  /// 위젯의 UI를 결정하는 표시 모드입니다.
  final IssueGrainDisplayMode displayMode;

  const IssueGrainItem({
    super.key,
    required this.postId,
    this.onTap,
    this.displayMode = IssueGrainDisplayMode.mapPreview,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grainAsync = ref.watch(issueGrainProvider(postId));

    return grainAsync.when(
      loading: () => const SizedBox(
        height: 150, // 로딩 중 고정 높이를 주어 UI 깜빡임 방지
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, stack) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: Text('오류: $e')),
      ),
      data: (grain) {
        // displayMode에 따라 적절한 레이아웃을 선택합니다.
        Widget content;
        switch (displayMode) {
          case IssueGrainDisplayMode.mapPreview:
          case IssueGrainDisplayMode.boardPreview:
            content = _buildPreviewLayout(context, grain, displayMode);
            break;
          case IssueGrainDisplayMode.fullView:
            content = _buildFullLayout(context, grain);
            break;
        }

        return InkWell(
          onTap: onTap,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: content,
              ),
              Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
            ],
          ),
        );
      },
    );
  }

  /// '미리보기' 모드 (mapPreview, boardPreview)를 위한 레이아웃을 빌드합니다.
  Widget _buildPreviewLayout(
    BuildContext context,
    IssueGrain grain,
    IssueGrainDisplayMode mode,
  ) {
    // '더보기' 표시를 위해 텍스트가 최대 줄 수를 초과하는지 계산합니다.
    const maxLinesForBoardPreview = 5;
    final textPainter = TextPainter(
      text: TextSpan(
        text: grain.content,
        style: const TextStyle(height: 1.5, fontSize: 15),
      ),
      maxLines: maxLinesForBoardPreview,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: MediaQuery.of(context).size.width - 64); // 좌우 패딩 고려
    final isTextOverflow = textPainter.didExceedMaxLines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            UserProfileLine(profileImageUrl: grain.author.profileImageUrl),
            const SizedBox(width: 8),
            Expanded(child: _buildAuthorRow(grain)),
          ],
        ),
        const SizedBox(height: 16),

        if (mode == IssueGrainDisplayMode.boardPreview && isTextOverflow)
          InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  grain.content,
                  maxLines: maxLinesForBoardPreview,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(height: 1.5, fontSize: 15),
                ),
                const SizedBox(height: 4),
                // ✅ 'Align' 위젯을 제거하여 왼쪽 정렬로 변경
                const Text(
                  "...더보기",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else
          Text(
            grain.content,
            style: const TextStyle(height: 1.5, fontSize: 15),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),

        if (mode == IssueGrainDisplayMode.boardPreview &&
            grain.photoUrls.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ImageCarousel(imageUrls: grain.photoUrls),
          ),

        if (mode == IssueGrainDisplayMode.mapPreview &&
            grain.photoUrls.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Row(
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  '사진 ${grain.photoUrls.length}장 보기',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

        InteractionToolbar(grain: grain, onTap: onTap),
      ],
    );
  }

  /// '전체보기' 모드 (fullView)를 위한 레이아웃을 빌드합니다.
  Widget _buildFullLayout(BuildContext context, IssueGrain grain) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            UserProfileLine(profileImageUrl: grain.author.profileImageUrl),
            const SizedBox(width: 8),
            Expanded(child: _buildAuthorRow(grain)),
          ],
        ),
        const SizedBox(height: 16),
        Text(grain.content, style: const TextStyle(height: 1.6, fontSize: 15)),
        if (grain.photoUrls.isNotEmpty) ...[
          const SizedBox(height: 16),
          ImageCarousel(imageUrls: grain.photoUrls),
        ],
        InteractionToolbar(grain: grain, onTap: onTap),
      ],
    );
  }

  /// 작성자 정보 Row를 만드는 공통 위젯입니다.
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

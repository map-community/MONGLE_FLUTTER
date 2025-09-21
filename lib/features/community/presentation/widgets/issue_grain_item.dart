import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/action_toolbar.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/image_carousel.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/interaction_toolbar.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/stats_and_comments.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/user_profile_line.dart';
import 'package:mongle_flutter/features/community/providers/issue_grain_providers.dart';
import 'package:timeago/timeago.dart' as timeago;

class IssueGrainItem extends ConsumerWidget {
  final String postId;
  // 이 위젯이 미리보기 모드로 렌더링되어야 하는지 결정하는 플래그입니다.
  // 기본값은 false로 설정하여, 이 위젯이 다른 곳에서 사용될 때 문제가 없도록 합니다.
  final bool isPreview;

  const IssueGrainItem({
    super.key,
    required this.postId,
    this.isPreview = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. postId에 해당하는 '알갱이' 데이터의 상태를 구독(watch)합니다.
    final grainAsync = ref.watch(issueGrainProvider(postId));

    // 2. AsyncValue의 when을 사용해 로딩, 에러, 데이터 상태에 따라 다른 UI를 보여줍니다.
    return grainAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, stack) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: Text('데이터를 불러오는 데 실패했습니다: $e')),
      ),
      data: (grain) {
        final int? maxLines = isPreview ? 5 : null; // 미리보기일 때 5줄 제한

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              // ⭐️ 1. IntrinsicHeight로 Row를 감싸줍니다.
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 40,
                      child: UserProfileLine(
                        profileImageUrl: grain.author.profileImageUrl,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 상단: 닉네임과 작성 시간
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                grain.author.nickname,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                // ⭐️ timeago.format() 함수로 DateTime을 '방금 전', '10분 전' 등으로 변환
                                timeago.format(grain.createdAt, locale: 'ko'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            grain.content,
                            style: const TextStyle(height: 1.5),
                            maxLines: maxLines, // 동적으로 최대 라인 수 적용
                            overflow: TextOverflow.ellipsis, // 글자가 넘치면 ...으로 표시
                          ),

                          // 미리보기 상태이고 글자가 잘렸을 경우 "더보기" 표시
                          if (isPreview &&
                              (grain.content.split('\n').length > 5))
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                '...더보기',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ),

                          // 이미지 캐러셀
                          if (grain.photoUrls.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            // 외부에서 AspectRatio로 감싸 크기를 강제하던 코드를 삭제하고,
                            // isPreview 상태만 직접 전달하여 ImageCarousel이 스스로 크기를 결정하도록 합니다.
                            ImageCarousel(
                              imageUrls: grain.photoUrls,
                              isPreview: isPreview,
                            ),
                          ],
                          InteractionToolbar(grain: grain),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/issue_grain_item.dart';
import 'package:mongle_flutter/features/community/providers/issue_grain_providers.dart';
import 'package:mongle_flutter/features/map/presentation/providers/map_interaction_providers.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/map_sheet_strategy.dart';
import 'package:mongle_flutter/features/map/presentation/viewmodels/map_viewmodel.dart';
import 'package:mongle_flutter/features/map/presentation/widgets/map_view.dart';
import 'package:mongle_flutter/features/map/presentation/widgets/multi_stage_bottom_sheet.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(mapViewModelProvider);
    // 1. 바텀시트의 현재 높이를 구독
    final sheetHeight = ref.watch(mapSheetStrategyProvider);
    // 2. 화면 전체 높이를 가져옴
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // 3. Stack 위젯으로 지도와 바텀시트를 겹치게 함
      body: Stack(
        children: [
          // 지도 UI (화면 전체를 차지)
          mapState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (message) => Center(child: Text(message)),
            data: (initialPosition, mapObjects) {
              return MapView(
                initialPosition: initialPosition,
                bottomPadding: screenHeight * sheetHeight,
              );
            },
          ),

          // 바텀시트 UI
          MultiStageBottomSheet(
            strategyProvider: mapSheetStrategyProvider,
            minSnapSize: peekFraction,
            maxSnapSize: fullFraction,
            // 5. 3가지 높이에 모두 달라붙도록 snapSizes 설정
            snapSizes: const [peekFraction, grainPreviewFraction, fullFraction],
            builder: (context, scrollController) {
              // 1. 현재 선택된 오버레이의 고유 ID를 구독합니다.
              final selectedGrainId = ref.watch(selectedGrainIdProvider);
              final selectedCloudId = ref.watch(selectedCloudIdProvider);

              // 1. 선택된 알갱이 ID가 있다면 (알갱이를 탭했다면)
              if (selectedGrainId != null) {
                return ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    _buildHandle(),
                    IssueGrainItem(postId: selectedGrainId),
                  ],
                );
              }
              // 2. 선택된 구름 ID가 있다면 (구름을 탭했다면)
              else if (selectedCloudId != null) {
                final postsInCloudAsync = ref.watch(
                  issueGrainsInCloudProvider(selectedCloudId),
                );

                return postsInCloudAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) =>
                      Center(child: Text('게시물을 불러올 수 없습니다: $err')),
                  data: (posts) {
                    return ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.zero,
                      itemCount: posts.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) return _buildHandle();
                        final post = posts[index - 1];
                        return IssueGrainItem(postId: post.postId);
                      },
                    );
                  },
                );
              }
              // 3. 아무것도 선택되지 않았다면 기본 UI를 보여줍니다.
              else {
                return ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    _buildHandle(),
                    const ListTile(title: Text("주변 이슈 목록 (구름)")),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // 바텀시트 핸들 UI를 위한 작은 헬퍼 위젯
  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12.0),
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

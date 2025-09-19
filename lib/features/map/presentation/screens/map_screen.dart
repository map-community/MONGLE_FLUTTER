import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/issue_grain_item.dart';
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
            data: (initialPosition) {
              // 4. 바텀시트 높이에 따라 계산된 실제 패딩 값을 MapView에 전달
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
              // 6. 선택된 마커 ID를 구독하여 UI 분기 처리
              final selectedId = ref.watch(selectedMarkerIdProvider);

              // 선택된 마커가 없을 때 (기본 목록 뷰)
              if (selectedId == null) {
                return ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    _buildHandle(),
                    const ListTile(title: Text("주변 이슈 목록 1 (구름)")),
                    const ListTile(title: Text("주변 이슈 목록 2 (구름)")),
                    ...List.generate(
                      20,
                      (index) => ListTile(title: Text("더 보기 ${index + 1}")),
                    ),
                  ],
                );
              }
              // 선택된 마커가 있을 때 ('알갱이' 미리보기 뷰)
              else {
                return ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    _buildHandle(),
                    // 기존 Card 위젯 대신, IssueGrainItem을 사용합니다.
                    IssueGrainItem(postId: selectedId),
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

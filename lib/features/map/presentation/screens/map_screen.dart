import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/community/domain/entities/issue_grain.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/issue_grain_item.dart';
import 'package:mongle_flutter/features/community/providers/issue_grain_providers.dart';
import 'package:mongle_flutter/features/map/presentation/providers/map_interaction_providers.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/map_sheet_strategy.dart';
import 'package:mongle_flutter/features/map/presentation/viewmodels/map_viewmodel.dart';
import 'package:mongle_flutter/features/map/presentation/widgets/map_view.dart';
import 'package:mongle_flutter/features/map/presentation/widgets/multi_stage_bottom_sheet.dart';

const double kHandleVerticalMargin = 12.0;
const double kHandleHeight = 5.0;
const double kTotalHandleAreaHeight =
    (kHandleVerticalMargin * 2) + kHandleHeight; // 29.0
const double kBottomSheetBottomPadding = 16.0;

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(mapViewModelProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final sheetState = ref.watch(mapSheetStrategyProvider);

    final selectedGrainId = ref.watch(selectedGrainIdProvider);

    final List<double> snapSizes;
    if (selectedGrainId != null) {
      snapSizes = [peekFraction, grainPreviewFraction, fullFraction];
    } else {
      snapSizes = [peekFraction, fullFraction];
    }

    return Scaffold(
      // Stack 위젯으로 지도와 바텀시트를 겹치게 함
      body: Stack(
        children: [
          // 지도 UI (화면 전체를 차지)
          mapState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (message) => Center(child: Text(message)),
            data: (initialPosition, mapObjects) {
              return MapView(
                initialPosition: initialPosition,
                bottomPadding: screenHeight * sheetState.height,
              );
            },
          ),

          // 바텀시트 UI
          MultiStageBottomSheet(
            strategyProvider: mapSheetStrategyProvider,
            minSnapSize: peekFraction,
            maxSnapSize: fullFraction,
            snapSizes: snapSizes,
            builder: (context, scrollController) {
              if (selectedGrainId != null) {
                final bool isPreview = sheetState.height < (fullFraction - 0.1);
                final displayMode = isPreview
                    ? IssueGrainDisplayMode.mapPreview
                    : IssueGrainDisplayMode.fullView;

                return ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    _buildHandle(),
                    IssueGrainItem(
                      key: ValueKey(selectedGrainId),
                      postId: selectedGrainId,
                      displayMode: displayMode,
                    ),
                  ],
                );
              }
              // 아무것도 선택되지 않았다면 기본 UI를 보여줍니다.
              else {
                return ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    _buildHandle(),
                    // [수정] 기존 코드의 Text(":)") 부분은 사용자가 어떤 상황인지 알기 어려워,
                    // 원래의 '주변 이슈 목록' 텍스트로 되돌려놓았습니다.
                    const ListTile(title: Text("주변 이슈 목록(구름)")),
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
        margin: const EdgeInsets.symmetric(vertical: kHandleVerticalMargin),
        width: 40,
        height: kHandleHeight,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

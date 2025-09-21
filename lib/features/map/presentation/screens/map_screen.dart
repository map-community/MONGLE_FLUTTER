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

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(mapViewModelProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final sheetState = ref.watch(mapSheetStrategyProvider);

    final selectedGrainId = ref.watch(selectedGrainIdProvider);
    final selectedCloudId = ref.watch(selectedCloudIdProvider);

    final grainPreviewHeight = ref.watch(grainPreviewFractionProvider);

    final List<double> snapSizes;
    if (selectedCloudId != null) {
      snapSizes = [peekFraction, fullFraction];
    } else if (selectedGrainId != null) {
      // Provider에서 읽어온 동적 높이를 사용합니다.
      snapSizes = [peekFraction, grainPreviewHeight, fullFraction];
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
                return ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    _buildHandle(),
                    _MeasuredIssueGrainItem(
                      key: ValueKey(selectedGrainId),
                      postId: selectedGrainId,
                      isPreview: isPreview,
                      onMeasured: (measuredFraction) {
                        // [수정] 콜백이 호출되면 로컬 변수가 아닌 Provider의 상태를 업데이트합니다.
                        ref.read(grainPreviewFractionProvider.notifier).state =
                            measuredFraction;
                        ref
                            .read(mapSheetStrategyProvider.notifier)
                            .updatePreviewHeight(measuredFraction);
                      },
                    ),
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

/// IssueGrainItem 위젯의 높이를 측정하여 Provider를 업데이트하는 책임을 가지는 위젯
class _MeasuredIssueGrainItem extends ConsumerStatefulWidget {
  final String postId;
  final bool isPreview;
  final Function(double) onMeasured;

  const _MeasuredIssueGrainItem({
    super.key,
    required this.postId,
    required this.isPreview,
    required this.onMeasured,
  });

  @override
  ConsumerState<_MeasuredIssueGrainItem> createState() =>
      _MeasuredIssueGrainItemState();
}

class _MeasuredIssueGrainItemState
    extends ConsumerState<_MeasuredIssueGrainItem> {
  final _key = GlobalKey();

  void _measureHeight() {
    final context = _key.currentContext;
    if (context != null && context.size != null) {
      final screenHeight = MediaQuery.of(context).size.height;
      final pixelHeight = context.size!.height;
      final totalSheetHeight = pixelHeight + 29.0 + 16.0;

      if (totalSheetHeight > 0) {
        final calculatedFraction = totalSheetHeight / screenHeight;
        final newFraction = calculatedFraction > 0.45
            ? 0.45
            : calculatedFraction;

        // Provider를 직접 업데이트하는 대신, 전달받은 콜백 함수를 실행합니다.
        widget.onMeasured(newFraction);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // issueGrainProvider의 상태가 '데이터 로딩 완료'로 변경될 때 높이를 측정합니다.
    ref.listen<AsyncValue<IssueGrain>>(issueGrainProvider(widget.postId), (
      previous,
      next,
    ) {
      if (!next.isLoading && next.hasValue) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _measureHeight());
      }
    });

    // 실제 UI를 렌더링하고, 측정을 위해 Key를 할당합니다.
    return Container(
      key: _key,
      child: IssueGrainItem(postId: widget.postId, isPreview: widget.isPreview),
    );
  }
}

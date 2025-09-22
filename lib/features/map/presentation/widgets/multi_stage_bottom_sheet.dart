import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/base_bottom_sheet_strategy.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/map_sheet_state.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/map_sheet_strategy.dart';

class MultiStageBottomSheet extends ConsumerStatefulWidget {
  /// 이 시트를 제어할 Strategy의 Provider입니다.
  final AutoDisposeStateNotifierProvider<MapSheetStrategy, MapSheetState>
  strategyProvider;

  /// 시트 내부에 실제로 그려질 내용을 만드는 빌더 함수입니다.
  final Widget Function(BuildContext context, ScrollController scrollController)
  builder;

  /// 시트가 자동으로 달라붙을 높이 지점 목록입니다.
  final List<double> snapSizes;
  final double minSnapSize;
  final double maxSnapSize;

  const MultiStageBottomSheet({
    super.key,
    required this.strategyProvider,
    required this.builder,
    required this.snapSizes,
    required this.minSnapSize,
    required this.maxSnapSize,
  });

  @override
  ConsumerState<MultiStageBottomSheet> createState() =>
      _MultiStageBottomSheetState();
}

class _MultiStageBottomSheetState extends ConsumerState<MultiStageBottomSheet> {
  final DraggableScrollableController _scrollController =
      DraggableScrollableController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- 1. Strategy -> UI 로의 데이터 흐름 ---
    // Strategy의 상태(높이)가 코드에 의해 변경될 때(e.g., 마커 탭),
    // 시트의 높이를 애니메이션으로 부드럽게 조절합니다.
    ref.listen<MapSheetState>(widget.strategyProvider, (previous, next) {
      // 상태 객체 안의 height 값을 사용합니다.
      if ((_scrollController.size - next.height).abs() < 0.01) return;
      if (_scrollController.isAttached) {
        _scrollController.animateTo(
          next.height,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          final currentFraction = _scrollController.size;
          // [수정] syncHeightFromUI는 이제 Strategy에 의해 직접 관리됩니다.
          //    BaseBottomSheetStrategy를 수정해야 합니다. (다음 단계에서 진행)
          ref
              .read(widget.strategyProvider.notifier)
              .syncHeightFromUI(currentFraction);
        }
        return false;
      },
      child: DraggableScrollableSheet(
        controller: _scrollController,
        initialChildSize: ref.read(widget.strategyProvider).height,
        minChildSize: widget.minSnapSize,
        maxChildSize: widget.maxSnapSize,
        snap: true,
        snapSizes: widget.snapSizes,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8),
              ],
            ),
            // 3. 외부에서 주입받은 builder를 호출하여 실제 콘텐츠를 그립니다.
            child: widget.builder(context, scrollController),
          );
        },
      ),
    );
  }
}

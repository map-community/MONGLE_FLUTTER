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
    ref.listen<MapSheetState>(widget.strategyProvider, (previous, next) {
      // 이전 높이와 다음 높이가 다를 때만 애니메이션 실행
      if (previous == null || previous.height == next.height)
        return; // 👈 null 체크 추가

      // ✨ 내려가는지 올라가는지 확인 ✨
      final bool isMovingDown = next.height < previous.height;

      // ✨ 내려갈 때는 더 짧은 duration (예: 200ms), 올라갈 때는 기존 duration (300ms) ✨
      final animationDuration = Duration(
        milliseconds: isMovingDown ? 200 : 300,
      );

      // 이번 프레임 렌더링(리빌드)이 끝난 후 애니메이션을 실행하도록 예약
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 컨트롤러가 아직 위젯 트리에 붙어있는지 안전하게 확인
        if (_scrollController.isAttached) {
          _scrollController.animateTo(
            next.height,
            duration: animationDuration, // 👈 수정된 duration 사용
            curve: Curves.easeOutCubic,
          );
        }
      });
    });

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          ref
              .read(widget.strategyProvider.notifier)
              .syncHeightFromUI(_scrollController.size);
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
            child: widget.builder(context, scrollController),
          );
        },
      ),
    );
  }
}

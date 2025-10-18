import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/base_bottom_sheet_strategy.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/map_sheet_state.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/map_sheet_strategy.dart';

/// 다단계 스냅 기능을 가진 바텀시트 위젯
class MultiStageBottomSheet extends ConsumerStatefulWidget {
  final AutoDisposeStateNotifierProvider<MapSheetStrategy, MapSheetState>
  strategyProvider;
  final Widget Function(BuildContext context, ScrollController scrollController)
  builder;
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

  /// 사용자가 현재 드래그 중인지 추적
  bool _isUserDragging = false;

  /// 마지막으로 동기화된 높이 (중복 호출 방지)
  double? _lastSyncedHeight;

  /// 🔥 드래그 중 도달한 snap 위치 (드래그 종료 후 즉시 동기화용)
  double? _pendingSnapHeight;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScrollControllerChange);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScrollControllerChange);
    _scrollController.dispose();
    super.dispose();
  }

  /// DraggableScrollableController의 변화를 감지하는 리스너
  void _onScrollControllerChange() {
    if (!mounted || !_scrollController.isAttached) return;

    final strategy = ref.read(widget.strategyProvider.notifier);
    final currentHeight = _scrollController.size;

    // 프로그램 애니메이션 중에는 무시
    if (strategy.isAnimating) {
      return;
    }

    // 🔥 핵심: 드래그 중이면 snap 위치 도달 여부만 확인하고 기록
    if (_isUserDragging) {
      final isAtSnapPosition = widget.snapSizes.any(
        (snap) => (currentHeight - snap).abs() < 0.001,
      );

      if (isAtSnapPosition) {
        print("📏 드래그 중 snap 위치 도달 감지: $currentHeight (대기 중)");
        _pendingSnapHeight = currentHeight;
      }
      return;
    }

    // 드래그 중이 아닐 때는 즉시 동기화
    final isAtSnapPosition = widget.snapSizes.any(
      (snap) => (currentHeight - snap).abs() < 0.001,
    );

    if (isAtSnapPosition) {
      if (_lastSyncedHeight == null ||
          (currentHeight - _lastSyncedHeight!).abs() > 0.001) {
        print("📏 ✅ Snap 위치 도달: $currentHeight → 즉시 동기화");
        _lastSyncedHeight = currentHeight;
        strategy.syncHeightFromUI(currentHeight);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Strategy 상태 변경 감지 → 프로그램 애니메이션 실행
    ref.listen<MapSheetState>(widget.strategyProvider, (previous, next) {
      print(
        "👂 STATE LISTEN: 상태 변경 감지! "
        "이전 높이: ${previous?.height}, 다음 높이: ${next.height}. "
        "이전 모드: ${previous?.mode}, 다음 모드: ${next.mode}",
      );

      if (previous == null || (previous.height - next.height).abs() < 0.001) {
        print("👂 STATE LISTEN: 높이 변경 없음, 애니메이션 건너뜀.");
        return;
      }

      final bool isMovingDown = next.height < previous.height;
      final animationDuration = Duration(
        milliseconds: isMovingDown ? 200 : 300,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.isAttached) {
          final strategyNotifier = ref.read(widget.strategyProvider.notifier);

          strategyNotifier.notifyAnimationStart();
          print("🎬 프로그램 애니메이션 시작: ${next.height}");

          _lastSyncedHeight = null;

          _scrollController
              .animateTo(
                next.height,
                duration: animationDuration,
                curve: Curves.easeOutCubic,
              )
              .whenComplete(() {
                if (mounted) {
                  print("🎬 프로그램 애니메이션 완료");
                  strategyNotifier.notifyAnimationComplete();
                  _lastSyncedHeight = next.height;
                }
              });
        }
      });
    });

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final strategy = ref.read(widget.strategyProvider.notifier);

        // 사용자 드래그 시작
        if (notification is ScrollStartNotification) {
          if (strategy.isAnimating) {
            print("⚠️ 사용자가 애니메이션 중 터치! 즉시 제어권 이양");
            strategy.notifyAnimationComplete();
          }

          _lastSyncedHeight = null;
          _pendingSnapHeight = null; // 대기 중인 snap 초기화
          _isUserDragging = true;
          print("👆 사용자 드래그 시작");
          return false;
        }

        // 🔥 사용자 드래그 종료 - 핵심!
        if (notification is ScrollEndNotification && _isUserDragging) {
          print("👆 사용자 드래그 종료");
          _isUserDragging = false;

          // 🔥 드래그 중 snap 위치에 도달했으면 즉시 동기화!
          if (_pendingSnapHeight != null) {
            print("🎯 대기 중이던 snap 위치로 즉시 동기화: $_pendingSnapHeight");

            if (_lastSyncedHeight == null ||
                (_pendingSnapHeight! - _lastSyncedHeight!).abs() > 0.001) {
              _lastSyncedHeight = _pendingSnapHeight;
              strategy.syncHeightFromUI(_pendingSnapHeight!);
            }

            _pendingSnapHeight = null;
          }

          return false;
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
          final currentState = ref.watch(widget.strategyProvider);
          print(
            "🏗️ BUILDER: 시트 내용 빌드. "
            "모드=${currentState.mode}, 높이=${currentState.height}, "
            "ID=${currentState.selectedGrainId}",
          );

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

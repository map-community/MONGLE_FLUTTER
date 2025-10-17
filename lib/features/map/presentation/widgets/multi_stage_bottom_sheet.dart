import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/base_bottom_sheet_strategy.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/map_sheet_state.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/map_sheet_strategy.dart';

/// 다단계 스냅 기능을 가진 바텀시트 위젯
///
/// 특징:
/// - DraggableScrollableSheet를 기반으로 구현
/// - 여러 단계의 고정 높이(snapSizes)에 자동으로 달라붙음
/// - Strategy 패턴을 통해 논리적 상태와 UI 상태 동기화
///
/// 핵심 동작:
/// 1. Strategy의 상태 변경 감지 → 프로그램 애니메이션 실행
/// 2. 사용자 드래그 감지 → 드래그 완료 후 Strategy와 동기화
/// 3. 애니메이션 중 사용자 터치 → 즉시 제어권 이양
class MultiStageBottomSheet extends ConsumerStatefulWidget {
  /// 이 시트를 제어할 Strategy의 Provider
  final AutoDisposeStateNotifierProvider<MapSheetStrategy, MapSheetState>
  strategyProvider;

  /// 시트 내부에 실제로 그려질 내용을 만드는 빌더 함수
  final Widget Function(BuildContext context, ScrollController scrollController)
  builder;

  /// 시트가 자동으로 달라붙을 높이 지점 목록 (화면 높이 대비 비율)
  final List<double> snapSizes;

  /// 시트의 최소 높이 (화면 높이 대비 비율)
  final double minSnapSize;

  /// 시트의 최대 높이 (화면 높이 대비 비율)
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
  /// DraggableScrollableSheet를 제어하는 컨트롤러
  final DraggableScrollableController _scrollController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Strategy의 상태 변경을 감지하여 프로그램 애니메이션 실행
    ref.listen<MapSheetState>(widget.strategyProvider, (previous, next) {
      print(
        "👂 STATE LISTEN: 상태 변경 감지! "
        "이전 높이: ${previous?.height}, 다음 높이: ${next.height}. "
        "이전 모드: ${previous?.mode}, 다음 모드: ${next.mode}",
      );

      // 높이 변경이 없으면 애니메이션 불필요
      if (previous == null || previous.height == next.height) {
        print("👂 STATE LISTEN: 높이 변경 없음, 애니메이션 건너뜀.");
        return;
      }

      // 올라가는 애니메이션과 내려가는 애니메이션의 속도 차별화
      // 내려갈 때는 더 빠르게(200ms), 올라갈 때는 부드럽게(300ms)
      final bool isMovingDown = next.height < previous.height;
      final animationDuration = Duration(
        milliseconds: isMovingDown ? 200 : 300,
      );

      // 현재 프레임의 리빌드가 완료된 후 애니메이션 시작
      // 이는 DraggableScrollableSheet가 완전히 준비된 후 animateTo를 호출하기 위함
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.isAttached) {
          // Strategy에게 애니메이션 시작 알림
          // 이 시점부터 minimize(), syncHeightFromUI() 호출은 무시됨
          ref.read(widget.strategyProvider.notifier).notifyAnimationStart();

          print("🎬 프로그램 애니메이션 시작: ${next.height}");

          _scrollController
              .animateTo(
                next.height,
                duration: animationDuration,
                curve: Curves.easeOutCubic,
              )
              .whenComplete(() {
                if (mounted) {
                  print("🎬 프로그램 애니메이션 완료");
                  // Strategy에게 애니메이션 완료 알림
                  // 이제 다시 minimize(), syncHeightFromUI() 호출이 정상 처리됨
                  ref
                      .read(widget.strategyProvider.notifier)
                      .notifyAnimationComplete();
                }
              });
        }
      });
    });

    // 사용자 스크롤 이벤트 감지 및 처리
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final strategy = ref.read(widget.strategyProvider.notifier);

        // 케이스 1: 프로그램 애니메이션 중 사용자 터치
        if (strategy.isAnimating && notification is ScrollStartNotification) {
          print("⚠️ 사용자가 애니메이션 중 터치! 즉시 제어권 이양");
          strategy.notifyAnimationComplete();
          return false;
        }

        // 케이스 2: 프로그램 애니메이션 중 ScrollEnd
        if (strategy.isAnimating && notification is ScrollEndNotification) {
          print("🚫 프로그램 애니메이션 중이므로 ScrollEnd 무시");
          return false;
        }

        // 케이스 3: 사용자 드래그 완료
        if (!strategy.isAnimating && notification is ScrollEndNotification) {
          print("👆 사용자 드래그 종료 감지");

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || !_scrollController.isAttached) return;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || !_scrollController.isAttached) return;

              final snappedHeight = _scrollController.size;
              print("🎯 SNAP 완료: $snappedHeight → Strategy 동기화");

              if (!strategy.isAnimating) {
                strategy.syncHeightFromUI(snappedHeight);
              }
            });
          });
        }

        return false;
      },
      child: DraggableScrollableSheet(
        controller: _scrollController,
        // Strategy의 초기 높이를 시트의 초기 높이로 설정
        initialChildSize: ref.read(widget.strategyProvider).height,
        minChildSize: widget.minSnapSize,
        maxChildSize: widget.maxSnapSize,
        snap: true, // 자동 snap 기능 활성화
        snapSizes: widget.snapSizes, // snap될 높이 지점들
        builder: (BuildContext context, ScrollController scrollController) {
          // 디버깅을 위한 현재 상태 출력
          final currentState = ref.watch(widget.strategyProvider);
          print(
            "🏗️ BUILDER: 시트 내용 빌드. "
            "모드=${currentState.mode}, 높이=${currentState.height}, "
            "ID=${currentState.selectedGrainId}",
          );

          // 시트의 시각적 스타일 정의
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
            // 실제 시트 내용은 builder 함수에서 제공
            child: widget.builder(context, scrollController),
          );
        },
      ),
    );
  }
}

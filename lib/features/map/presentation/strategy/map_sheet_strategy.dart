import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/map/presentation/providers/map_interaction_providers.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/base_bottom_sheet_strategy.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/map_sheet_state.dart';

// MONGLE 지도 바텀시트의 높이 상태(Fraction) 정의
const double peekFraction = 0.1; // 최소 높이 (핸들만 보임)
const double grainPreviewFraction = 0.4; // '알갱이' 선택 시 미리보기 높이
const double fullFraction = 0.95; // 전체 스레드 높이

/// 지도 바텀시트의 상태를 관리하는 Strategy 클래스
class MapSheetStrategy extends StateNotifier<MapSheetState> {
  final Ref _ref;

  /// 현재 바텀시트가 프로그램에 의해 애니메이션 중인지 추적하는 플래그
  bool _isAnimating = false;

  /// 외부에서 애니메이션 상태를 읽을 수 있도록 제공하는 getter
  bool get isAnimating => _isAnimating;

  MapSheetStrategy(this._ref)
    : super(const MapSheetState(height: peekFraction)) {
    print("✨ STRATEGY: MapSheetStrategy 생성됨. 초기 상태: $state");
  }

  /// MultiStageBottomSheet에서 프로그램 애니메이션 시작 시 호출
  void notifyAnimationStart() {
    _isAnimating = true;
    print("🎬 STRATEGY: 애니메이션 시작 (_isAnimating = true)");
  }

  /// MultiStageBottomSheet에서 프로그램 애니메이션 완료 시 호출
  void notifyAnimationComplete() {
    _isAnimating = false;
    print("🎬 STRATEGY: 애니메이션 완료 (_isAnimating = false)");
  }

  /// 알갱이(Grain) 미리보기 모드로 전환
  void showGrainPreview(String grainId) {
    print(
      "🚀 STRATEGY: showGrainPreview 호출 (ID: $grainId). "
      "현재 상태: 모드=${state.mode}, 높이=${state.height}",
    );

    state = MapSheetState(
      mode: SheetMode.preview,
      selectedGrainId: grainId,
      height: grainPreviewFraction,
    );

    print(
      "🚀 STRATEGY: showGrainPreview 상태 변경 완료. "
      "새 상태: 모드=${state.mode}, 높이=${state.height}",
    );
  }

  /// 알갱이(Grain) 전체 상세보기 모드로 전환
  void showGrainDetail(String grainId) {
    print(
      "🚀 STRATEGY: showGrainDetail 호출 (ID: $grainId). "
      "현재 상태: 모드=${state.mode}, 높이=${state.height}",
    );

    state = MapSheetState(
      mode: SheetMode.full,
      selectedGrainId: grainId,
      height: fullFraction,
    );

    print(
      "🚀 STRATEGY: showGrainDetail 상태 변경 완료. "
      "새 상태: 모드=${state.mode}, 높이=${state.height}",
    );
  }

  /// 바텀시트를 최소화 모드로 전환
  void minimize() {
    // ✅ 애니메이션 중에는 무시
    if (_isAnimating) {
      print(
        "⚠️ STRATEGY: minimize 호출 무시됨 (애니메이션 진행 중). "
        "현재 상태: 모드=${state.mode}, 높이=${state.height}",
      );
      return;
    }

    print(
      "🚀 STRATEGY: minimize 호출. "
      "현재 상태: 모드=${state.mode}, 높이=${state.height}",
    );

    state = const MapSheetState(
      mode: SheetMode.minimized,
      selectedGrainId: null,
      height: peekFraction,
    );

    print(
      "🚀 STRATEGY: minimize 상태 변경 완료. "
      "새 상태: 모드=${state.mode}, 높이=${state.height}",
    );
  }

  /// UI(DraggableScrollableSheet)의 현재 높이를 받아 논리적 상태와 동기화
  ///
  /// 🔑 핵심 수정 사항:
  /// - selectedGrainId가 없으면 무조건 minimized로만 이동
  /// - selectedGrainId가 있을 때만 preview ↔ full 전환 허용
  @override
  void syncHeightFromUI(double currentHeight) {
    // ✅ 애니메이션 중에는 동기화도 무시
    if (_isAnimating) {
      print(
        "⚠️ STRATEGY: syncHeightFromUI 무시됨 (애니메이션 진행 중). "
        "전달된 높이: $currentHeight",
      );
      return;
    }

    print(
      "🔄 STRATEGY: syncHeightFromUI 호출 (전달된 높이: $currentHeight). "
      "현재 상태: 모드=${state.mode}, 높이=${state.height}, ID=${state.selectedGrainId}",
    );

    // 가장 가까운 snap 위치 찾기
    const snapSizes = [peekFraction, grainPreviewFraction, fullFraction];
    double closestSnap = snapSizes.reduce(
      (a, b) => (currentHeight - a).abs() < (currentHeight - b).abs() ? a : b,
    );

    print("🔄 STRATEGY: 가장 가까운 snap 위치: $closestSnap");

    // 🔥 핵심 수정: selectedGrainId가 없으면 무조건 minimized로만 이동
    if (state.selectedGrainId == null) {
      print("🔄 STRATEGY: selectedGrainId가 null이므로 minimized로 강제 변경");
      state = const MapSheetState(
        mode: SheetMode.minimized,
        selectedGrainId: null,
        height: peekFraction,
      );
      return;
    }

    // ✅ 특수 규칙: Full 모드에서 Preview로 내려가려는 경우 Peek으로 강제 이동
    if (state.mode == SheetMode.full && closestSnap == grainPreviewFraction) {
      print("🔄 STRATEGY: Full → Preview 감지! Peek으로 강제 변경");
      closestSnap = peekFraction;
    }

    // snap 위치에 따라 적절한 SheetMode 결정
    SheetMode newMode;
    String? newGrainId;

    if (closestSnap == fullFraction) {
      // Full 모드: selectedGrainId 유지
      newMode = SheetMode.full;
      newGrainId = state.selectedGrainId;
    } else if (closestSnap == grainPreviewFraction) {
      // Preview 모드: selectedGrainId 유지
      newMode = SheetMode.preview;
      newGrainId = state.selectedGrainId;
    } else {
      // Minimized 모드: selectedGrainId 제거
      newMode = SheetMode.minimized;
      newGrainId = null;
    }

    print("🔄 STRATEGY: 계산된 모드: $newMode");

    // 상태 업데이트
    final newState = MapSheetState(
      mode: newMode,
      height: closestSnap,
      selectedGrainId: newGrainId,
    );

    // 실제로 상태가 변경된 경우에만 업데이트
    if (state.mode != newState.mode ||
        (state.height - newState.height).abs() > 0.001 ||
        state.selectedGrainId != newState.selectedGrainId) {
      print(
        "🔄 STRATEGY: 상태 업데이트! "
        "변경 전: $state -> 변경 후: $newState",
      );
      state = newState;
    } else {
      print("🔄 STRATEGY: 상태 변경 없음 (이미 동일한 상태)");
    }
  }
}

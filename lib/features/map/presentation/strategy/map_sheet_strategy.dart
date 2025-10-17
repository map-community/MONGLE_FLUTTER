import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/map/presentation/providers/map_interaction_providers.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/base_bottom_sheet_strategy.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/map_sheet_state.dart';

// MONGLE 지도 바텀시트의 높이 상태(Fraction) 정의
const double peekFraction = 0.1; // 최소 높이 (핸들만 보임)
const double grainPreviewFraction = 0.4; // '알갱이' 선택 시 미리보기 높이
const double fullFraction = 0.95; // 전체 스레드 높이

class MapSheetStrategy extends StateNotifier<MapSheetState> {
  final Ref _ref;

  MapSheetStrategy(this._ref)
    : super(const MapSheetState(height: peekFraction));

  /// '이슈 알갱이' 미리보기를 표시할 때 호출됩니다.
  void showGrainPreview(String grainId) {
    // 미리보기 모드로 상태 변경을 요청
    state = MapSheetState(
      mode: SheetMode.preview,
      selectedGrainId: grainId,
      height: grainPreviewFraction,
    );
  }

  /// 특정 '이슈 알갱이'의 상세 내용을 전체 화면으로 표시할 때 호출됩니다.
  void showGrainDetail(String grainId) {
    // 전체 보기 모드로 상태 변경을 요청
    state = MapSheetState(
      mode: SheetMode.full,
      selectedGrainId: grainId,
      height: fullFraction,
    );
  }

  /// 사용자가 지도를 탐색하거나 뒤로가기를 눌렀을 때 호출됩니다.
  void minimize() {
    // 최소화 모드로 상태 변경을 요청
    state = const MapSheetState(
      mode: SheetMode.minimized,
      selectedGrainId: null,
      height: peekFraction,
    );
  }

  void syncHeightFromUI(double currentHeight) {
    // 오차 허용 범위
    const tolerance = 0.01;

    // 1. 선택된 알갱이가 없으면 무조건 최소화 모드로 처리 (기존 로직 유지)
    if (state.selectedGrainId == null) {
      if (state.mode != SheetMode.minimized) {
        state = state.copyWith(
          mode: SheetMode.minimized,
          height: currentHeight, // UI에서 전달된 실제 높이 사용
        );
      }
      return;
    }

    // --- 이하 선택된 알갱이가 있을 때의 로직 ---

    // 2. 현재 높이를 기준으로 목표 모드를 계산 (기존 로직)
    SheetMode calculatedMode;
    if ((currentHeight - fullFraction).abs() < tolerance) {
      calculatedMode = SheetMode.full;
    } else if ((currentHeight - grainPreviewFraction).abs() < tolerance) {
      calculatedMode = SheetMode.preview;
    } else {
      calculatedMode = SheetMode.minimized;
    }

    // 3. ✨ 핵심 수정: 상태 전환 로직 ✨
    SheetMode finalMode = calculatedMode; // 최종적으로 결정될 모드
    double finalHeight = currentHeight; // 최종적으로 결정될 높이
    String? finalSelectedGrainId = state.selectedGrainId; // 선택된 알갱이 ID

    // 이전 모드가 'full'이었고, 계산된 새 모드가 'preview' 라면...
    if (state.mode == SheetMode.full && calculatedMode == SheetMode.preview) {
      // ... 강제로 'minimized' 모드로 변경하고, 높이도 peekFraction으로 설정!
      finalMode = SheetMode.minimized;
      finalHeight = peekFraction; // 높이도 강제로 최소 높이로 설정
      finalSelectedGrainId = null; // 최소화 모드에서는 선택된 알갱이 ID 해제
      print("🚀 Full -> Preview 감지! Minimized로 강제 전환!");
    }
    // 최소화 모드로 전환될 때는 항상 선택된 알갱이 ID 해제
    else if (calculatedMode == SheetMode.minimized) {
      finalSelectedGrainId = null;
    }

    // 4. 상태 업데이트: 현재 상태와 최종 결정된 상태가 다를 경우에만 업데이트
    if (state.mode != finalMode ||
        (state.height - finalHeight).abs() > tolerance ||
        state.selectedGrainId != finalSelectedGrainId) {
      state = state.copyWith(
        mode: finalMode,
        height: finalHeight, // 계산되거나 강제 지정된 높이 사용
        selectedGrainId: finalSelectedGrainId,
      );
    }
  }
}

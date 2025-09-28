import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/map/presentation/providers/map_interaction_providers.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/base_bottom_sheet_strategy.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/map_sheet_state.dart';

// MONGLE 지도 바텀시트의 높이 상태(Fraction) 정의
const double peekFraction = 0.1; // 최소 높이 (핸들만 보임)
const double grainPreviewFraction = 0.35; // '알갱이' 선택 시 미리보기 높이
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
    // 0.01 정도의 작은 오차는 무시
    const tolerance = 0.01;
    SheetMode newMode;

    // [핵심] 현재 높이가 어떤 모드에 가장 가까운지 판단합니다.
    if ((currentHeight - fullFraction).abs() < tolerance) {
      newMode = SheetMode.full;
    } else if ((currentHeight - grainPreviewFraction).abs() < tolerance) {
      newMode = SheetMode.preview;
    } else {
      newMode = SheetMode.minimized;
    }

    // 현재 상태와 달라졌을 때만 상태를 업데이트합니다.
    if (state.mode != newMode ||
        (state.height - currentHeight).abs() > tolerance) {
      // selectedGrainId는 최소화 모드가 아닐 때만 유지합니다.
      final newSelectedGrainId = (newMode == SheetMode.minimized)
          ? null
          : state.selectedGrainId;

      state = state.copyWith(
        mode: newMode,
        height: currentHeight,
        selectedGrainId: newSelectedGrainId,
      );
    }
  }
}

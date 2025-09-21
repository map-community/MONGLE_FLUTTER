import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/map/presentation/providers/map_interaction_providers.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/base_bottom_sheet_strategy.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/map_sheet_state.dart';

// MONGLE 지도 바텀시트의 높이 상태(Fraction) 정의
const double peekFraction = 0.1; // 최소 높이 (핸들만 보임)
const double grainPreviewFraction = 0.3; // '알갱이' 선택 시 미리보기 높이
const double fullFraction = 0.95; // '구름' 선택 시 전체 스레드 높이

class MapSheetStrategy extends StateNotifier<MapSheetState> {
  final Ref _ref;

  MapSheetStrategy(this._ref) : super(MapSheetState(height: peekFraction));

  /// '이슈 알갱이' 미리보기를 표시할 때 호출됩니다.
  void showGrainPreview(String grainId) {
    // 알갱이 Provider에 ID를 설정하고, 구름 Provider는 null로 초기화합니다.
    _ref.read(selectedGrainIdProvider.notifier).state = grainId;
    _ref.read(selectedCloudIdProvider.notifier).state = null;
  }

  void updatePreviewHeight(double newFraction) {
    if ((state.height - newFraction).abs() > 0.001) {
      state = MapSheetState(height: newFraction);
    }
  }

  /// '이슈 구름' 스레드 전체를 표시할 때 호출됩니다.
  void showCloudThread(String cloudId) {
    // 구름 Provider에 ID를 설정하고, 알갱이 Provider는 null로 초기화합니다.
    _ref.read(selectedCloudIdProvider.notifier).state = cloudId;
    _ref.read(selectedGrainIdProvider.notifier).state = null;
    state = const MapSheetState(height: fullFraction);
  }

  /// 사용자가 지도를 탐색할 때 호출됩니다.
  void minimize() {
    state = const MapSheetState(height: peekFraction);
  }

  void syncHeightFromUI(double currentHeight) {
    if ((state.height - currentHeight).abs() > 0.001) {
      state = MapSheetState(height: currentHeight);
    }
  }
}

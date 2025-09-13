import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/map/presentation/providers/map_interaction_providers.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/base_bottom_sheet_strategy.dart';

// MONGLE 지도 바텀시트의 높이 상태(Fraction) 정의
const double peekFraction = 0.1; // 최소 높이 (핸들만 보임)
const double grainPreviewFraction = 0.3; // '알갱이' 선택 시 미리보기 높이
const double fullFraction = 0.9; // '구름' 선택 시 전체 스레드 높이

class MapSheetStrategy extends BaseBottomSheetStrategy {
  final Ref _ref;

  // 바텀시트의 초기 높이는 peekFraction으로 시작합니다.
  MapSheetStrategy(this._ref) : super(peekFraction);

  /// '이슈 알갱이' 미리보기를 표시할 때 호출됩니다.
  void showGrainPreview(String markerId) {
    // 어떤 마커가 선택되었는지 ID를 기록하고, 높이를 preview 높이로 변경합니다.
    _ref.read(selectedMarkerIdProvider.notifier).state = markerId;
    state = grainPreviewFraction;
  }

  /// '이슈 구름' 스레드 전체를 표시할 때 호출됩니다.
  void showCloudThread(String markerId) {
    // 어떤 구름이 선택되었는지 ID를 기록하고, 높이를 full 높이로 변경합니다.
    _ref.read(selectedMarkerIdProvider.notifier).state = markerId;
    state = fullFraction;
  }

  /// 사용자가 지도를 탐색할 때 호출됩니다.
  void minimize() {
    // 선택된 마커 ID를 null로 초기화하고, 높이를 최소 높이로 변경합니다.
    _ref.read(selectedMarkerIdProvider.notifier).state = null;
    state = peekFraction;
  }
}

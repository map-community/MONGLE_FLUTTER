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
  void showGrainPreview(String grainId) {
    // 알갱이 Provider에 ID를 설정하고, 구름 Provider는 null로 초기화합니다.
    _ref.read(selectedGrainIdProvider.notifier).state = grainId;
    _ref.read(selectedCloudIdProvider.notifier).state = null;
    state = grainPreviewFraction;
  }

  /// '이슈 구름' 스레드 전체를 표시할 때 호출됩니다.
  void showCloudThread(String cloudId) {
    // 구름 Provider에 ID를 설정하고, 알갱이 Provider는 null로 초기화합니다.
    _ref.read(selectedCloudIdProvider.notifier).state = cloudId;
    _ref.read(selectedGrainIdProvider.notifier).state = null;
    state = fullFraction;
  }

  /// 사용자가 지도를 탐색할 때 호출됩니다.
  void minimize() {
    // 모든 선택 상태를 null로 초기화합니다.
    _ref.read(selectedGrainIdProvider.notifier).state = null;
    _ref.read(selectedCloudIdProvider.notifier).state = null;
    state = peekFraction;
  }
}

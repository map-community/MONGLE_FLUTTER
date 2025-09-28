import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/map/presentation/providers/map_interaction_providers.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/base_bottom_sheet_strategy.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/map_sheet_state.dart';

// MONGLE 지도 바텀시트의 높이 상태(Fraction) 정의
const double peekFraction = 0.1; // 최소 높이 (핸들만 보임)
const double grainPreviewFraction = 0.3; // '알갱이' 선택 시 미리보기 높이
const double fullFraction = 0.95; // 전체 스레드 높이

class MapSheetStrategy extends StateNotifier<MapSheetState> {
  final Ref _ref;

  MapSheetStrategy(this._ref) : super(MapSheetState(height: peekFraction));

  /// '이슈 알갱이' 미리보기를 표시할 때 호출됩니다.
  void showGrainPreview(String grainId) {
    _ref.read(selectedGrainIdProvider.notifier).state = grainId;
    state = const MapSheetState(height: grainPreviewFraction);
  }

  /// 특정 '이슈 알갱이'의 상세 내용을 전체 화면으로 표시할 때 호출됩니다.
  Future<void> showGrainDetail(String grainId) async {
    // 1. 시트 높이를 먼저 전체 화면으로 변경하여 애니메이션을 시작합니다.
    state = const MapSheetState(height: fullFraction);
    // 2. 애니메이션과 콘텐츠 로딩이 겹치지 않도록 짧은 지연을 줍니다.
    await Future.delayed(const Duration(milliseconds: 100));
    // 3. 선택된 알갱이 ID를 설정
    _ref.read(selectedGrainIdProvider.notifier).state = grainId;
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/map_sheet_strategy.dart';

/// MapSheetStrategy의 인스턴스를 생성하고 관리하며,
/// UI가 이 Strategy에 접근할 수 있도록 하는 핵심 Provider입니다.
final mapSheetStrategyProvider =
    StateNotifierProvider.autoDispose<MapSheetStrategy, double>(
      (ref) => MapSheetStrategy(ref),
    );

/// 사용자가 지도에서 선택한 마커(장소)의 ID를 관리하는 Provider입니다.
/// 이 상태가 바뀌면, 바텀시트의 내용이나 지도의 마커 모양 등이 바뀔 수 있습니다.
/// 초기에는 아무것도 선택되지 않았으므로 null 입니다.
final selectedMarkerIdProvider = StateProvider.autoDispose<String?>(
  (ref) => null,
);

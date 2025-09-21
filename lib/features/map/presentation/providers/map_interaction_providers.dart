import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/map_sheet_state.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/map_sheet_strategy.dart';

/// MapSheetStrategy의 인스턴스를 생성하고 관리하며,
/// UI가 이 Strategy에 접근할 수 있도록 하는 핵심 Provider입니다.
final mapSheetStrategyProvider =
    StateNotifierProvider.autoDispose<MapSheetStrategy, MapSheetState>(
      (ref) => MapSheetStrategy(ref),
    );

/// 선택된 '이슈 알갱이'의 ID만 관리하는 Provider
final selectedGrainIdProvider = StateProvider.autoDispose<String?>(
  (ref) => null,
);

/// 선택된 '구름'의 ID만 관리하는 Provider
final selectedCloudIdProvider = StateProvider.autoDispose<String?>(
  (ref) => null,
);

final grainPreviewFractionProvider = StateProvider.autoDispose<double>(
  (ref) => grainPreviewFraction,
);

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class BaseBottomSheetStrategy extends StateNotifier<double> {
  BaseBottomSheetStrategy(super.initialState);

  void syncHeightFromUI(double currentHeight) {
    if ((state - currentHeight).abs() > precisionErrorTolerance) {
      state = currentHeight;
    }
  }
}

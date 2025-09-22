import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'map_sheet_state.freezed.dart';

@freezed
abstract class MapSheetState with _$MapSheetState {
  const factory MapSheetState({required double height}) = _MapSheetState;
}

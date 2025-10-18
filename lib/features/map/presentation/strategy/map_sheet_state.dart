import 'package:freezed_annotation/freezed_annotation.dart';

part 'map_sheet_state.freezed.dart';

// 1. 시트의 상태를 명확하게 정의하는 enum 생성
enum SheetMode { minimized, preview, full }

@freezed
abstract class MapSheetState with _$MapSheetState {
  const factory MapSheetState({
    // 2. 현재 모드를 나타내는 상태 추가
    @Default(SheetMode.minimized) SheetMode mode,
    // 3. 선택된 알갱이 ID도 여기서 관리
    String? selectedGrainId,
    // 4. UI가 참조할 높이 값은 그대로 둡니다.
    required double height,
  }) = _MapSheetState;
}

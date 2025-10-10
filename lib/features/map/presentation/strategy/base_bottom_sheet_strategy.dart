import 'package:flutter_riverpod/flutter_riverpod.dart';

// [수정] 이제 이 클래스는 특정 상태 타입 'T'를 관리하도록 일반화(generic)합니다.
abstract class BaseBottomSheetStrategy<T> extends StateNotifier<T> {
  BaseBottomSheetStrategy(super.initialState);

  // [수정] 이 함수는 이제 추상 메서드가 되어, 자식 클래스에서 반드시 구현해야 합니다.
  void syncHeightFromUI(double currentHeight);
}

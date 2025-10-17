import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/map/presentation/providers/map_interaction_providers.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/base_bottom_sheet_strategy.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/map_sheet_state.dart';

// MONGLE 지도 바텀시트의 높이 상태(Fraction) 정의
const double peekFraction = 0.1; // 최소 높이 (핸들만 보임)
const double grainPreviewFraction = 0.4; // '알갱이' 선택 시 미리보기 높이
const double fullFraction = 0.95; // 전체 스레드 높이

/// 지도 바텀시트의 상태를 관리하는 Strategy 클래스
///
/// 핵심 책임:
/// 1. 바텀시트의 논리적 상태(모드, 높이, 선택된 알갱이) 관리
/// 2. 애니메이션 진행 상태 추적 (_isAnimating)
/// 3. 애니메이션 중 외부 이벤트(지도 탭, UI 동기화) 차단
class MapSheetStrategy extends StateNotifier<MapSheetState> {
  final Ref _ref;

  /// 현재 바텀시트가 프로그램에 의해 애니메이션 중인지 추적하는 플래그
  ///
  /// true일 때:
  /// - minimize(), syncHeightFromUI() 호출 무시
  /// - 사용자 터치는 허용하되, 터치 시 즉시 false로 변경
  bool _isAnimating = false;

  /// 외부에서 애니메이션 상태를 읽을 수 있도록 제공하는 getter
  /// MultiStageBottomSheet에서 이 값을 참조하여 단일 진실 공급원(SSOT) 유지
  bool get isAnimating => _isAnimating;

  MapSheetStrategy(this._ref)
    : super(const MapSheetState(height: peekFraction)) {
    print("✨ STRATEGY: MapSheetStrategy 생성됨. 초기 상태: $state");
  }

  /// MultiStageBottomSheet에서 프로그램 애니메이션 시작 시 호출
  /// 이 플래그가 true인 동안 minimize()와 syncHeightFromUI()는 무시됨
  void notifyAnimationStart() {
    _isAnimating = true;
    print("🎬 STRATEGY: 애니메이션 시작 (_isAnimating = true)");
  }

  /// MultiStageBottomSheet에서 프로그램 애니메이션 완료 시 호출
  /// 또는 사용자가 애니메이션 중 터치하여 중단시킬 때도 호출됨
  void notifyAnimationComplete() {
    _isAnimating = false;
    print("🎬 STRATEGY: 애니메이션 완료 (_isAnimating = false)");
  }

  /// 알갱이(Grain) 미리보기 모드로 전환
  ///
  /// 사용 시점: 사용자가 지도에서 알갱이 마커를 탭했을 때
  /// 결과: 바텀시트가 grainPreviewFraction(0.4) 높이로 올라가며 해당 알갱이 정보 표시
  void showGrainPreview(String grainId) {
    print(
      "🚀 STRATEGY: showGrainPreview 호출 (ID: $grainId). "
      "현재 상태: 모드=${state.mode}, 높이=${state.height}",
    );

    state = MapSheetState(
      mode: SheetMode.preview,
      selectedGrainId: grainId,
      height: grainPreviewFraction,
    );

    print(
      "🚀 STRATEGY: showGrainPreview 상태 변경 완료. "
      "새 상태: 모드=${state.mode}, 높이=${state.height}",
    );
  }

  /// 알갱이(Grain) 전체 상세보기 모드로 전환
  ///
  /// 사용 시점: 미리보기 상태에서 사용자가 더보기 버튼을 탭하거나 시트를 위로 스와이프했을 때
  /// 결과: 바텀시트가 fullFraction(0.95) 높이로 확장되며 전체 스레드 내용 표시
  void showGrainDetail(String grainId) {
    print(
      "🚀 STRATEGY: showGrainDetail 호출 (ID: $grainId). "
      "현재 상태: 모드=${state.mode}, 높이=${state.height}",
    );

    state = MapSheetState(
      mode: SheetMode.full,
      selectedGrainId: grainId,
      height: fullFraction,
    );

    print(
      "🚀 STRATEGY: showGrainDetail 상태 변경 완료. "
      "새 상태: 모드=${state.mode}, 높이=${state.height}",
    );
  }

  /// 바텀시트를 최소화 모드로 전환
  ///
  /// 사용 시점:
  /// - 사용자가 지도 배경(빈 공간)을 탭했을 때
  /// - 뒤로 가기 버튼을 눌렀을 때
  ///
  /// 중요: 애니메이션 진행 중(_isAnimating == true)에는 호출이 무시됨
  /// 이는 애니메이션 도중 지도 탭으로 인한 상태 꼬임을 방지하기 위함
  void minimize() {
    // ✅ 애니메이션 중에는 무시 - 핵심 버그 수정 포인트!
    if (_isAnimating) {
      print(
        "⚠️ STRATEGY: minimize 호출 무시됨 (애니메이션 진행 중). "
        "현재 상태: 모드=${state.mode}, 높이=${state.height}",
      );
      return;
    }

    print(
      "🚀 STRATEGY: minimize 호출. "
      "현재 상태: 모드=${state.mode}, 높이=${state.height}",
    );

    state = const MapSheetState(
      mode: SheetMode.minimized,
      selectedGrainId: null,
      height: peekFraction,
    );

    print(
      "🚀 STRATEGY: minimize 상태 변경 완료. "
      "새 상태: 모드=${state.mode}, 높이=${state.height}",
    );
  }

  /// UI(DraggableScrollableSheet)의 현재 높이를 받아 논리적 상태와 동기화
  ///
  /// 호출 시점:
  /// - 사용자가 시트를 드래그하여 손을 뗀 후 snap이 완료되었을 때
  ///
  /// 동작:
  /// 1. 전달받은 currentHeight를 기준으로 가장 가까운 snap 위치 계산
  /// 2. 해당 snap 위치에 맞는 SheetMode 결정
  /// 3. 상태 업데이트 (항상 정확한 snap 위치로 보정)
  ///
  /// 중요: 애니메이션 진행 중(_isAnimating == true)에는 호출이 무시됨
  @override
  void syncHeightFromUI(double currentHeight) {
    // ✅ 애니메이션 중에는 동기화도 무시
    if (_isAnimating) {
      print(
        "⚠️ STRATEGY: syncHeightFromUI 무시됨 (애니메이션 진행 중). "
        "전달된 높이: $currentHeight",
      );
      return;
    }

    print(
      "🔄 STRATEGY: syncHeightFromUI 호출 (전달된 높이: $currentHeight). "
      "현재 상태: 모드=${state.mode}, 높이=${state.height}, ID=${state.selectedGrainId}",
    );

    // 가장 가까운 snap 위치 찾기
    // DraggableScrollableSheet의 snap 동작과 일치하도록 정확한 snap 위치로 보정
    const snapSizes = [peekFraction, grainPreviewFraction, fullFraction];
    double closestSnap = snapSizes.reduce(
      (a, b) => (currentHeight - a).abs() < (currentHeight - b).abs() ? a : b,
    );

    print("🔄 STRATEGY: 가장 가까운 snap 위치: $closestSnap");

    // snap 위치에 따라 적절한 SheetMode 결정
    SheetMode newMode;
    if (closestSnap == fullFraction) {
      newMode = SheetMode.full;
    } else if (closestSnap == grainPreviewFraction) {
      newMode = SheetMode.preview;
    } else {
      newMode = SheetMode.minimized;
    }

    print("🔄 STRATEGY: 계산된 모드: $newMode");

    // 상태 업데이트
    // minimized 모드일 경우 선택된 알갱이 ID도 null로 초기화
    final newState = state.copyWith(
      mode: newMode,
      height: closestSnap, // ✅ 항상 정확한 snap 위치로 저장
      selectedGrainId: newMode == SheetMode.minimized
          ? null
          : state.selectedGrainId,
    );

    // 실제로 상태가 변경된 경우에만 업데이트
    if (state.mode != newState.mode ||
        (state.height - newState.height).abs() > 0.001 ||
        state.selectedGrainId != newState.selectedGrainId) {
      print(
        "🔄 STRATEGY: 상태 업데이트! "
        "변경 전: $state -> 변경 후: $newState",
      );
      state = newState;
    } else {
      print("🔄 STRATEGY: 상태 변경 없음 (이미 동일한 상태)");
    }
  }
}

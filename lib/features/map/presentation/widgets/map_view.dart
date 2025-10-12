// lib/features/map/presentation/widgets/map_view.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mongle_flutter/core/providers/config_provider.dart';
import 'package:mongle_flutter/features/auth/providers/user_provider.dart';
import 'package:mongle_flutter/features/map/presentation/manager/map_overlay_manager.dart';
import 'package:mongle_flutter/features/map/presentation/providers/map_interaction_providers.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/map_sheet_strategy.dart';
import 'package:mongle_flutter/features/map/presentation/viewmodels/map_viewmodel.dart';
import 'package:mongle_flutter/features/map/presentation/widgets/marker_factory.dart';

// ConsumerStatefulWidget으로 위젯의 생명주기와 ref를 모두 사용합니다.
class MapView extends ConsumerStatefulWidget {
  final NLatLng initialPosition;
  final double bottomPadding;

  const MapView({
    super.key,
    required this.initialPosition,
    this.bottomPadding = 0,
  });

  @override
  ConsumerState<MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<MapView> {
  NaverMapController? _mapController;
  MapOverlayManager? _overlayManager;
  final MarkerFactory _markerFactory = MarkerFactory();
  Timer? _debounce; // onCameraIdle 상태에서 디바운스를 위한 타이머 변수

  @override
  Widget build(BuildContext context) {
    // ref.listen을 사용하여 ViewModel의 상태 변화를 감지하고 오버레이를 업데이트합니다.
    ref.listen<MapState>(mapViewModelProvider, (previous, next) {
      // ViewModel의 상태가 'data'로 변경될 때만 오버레이를 업데이트합니다.
      next.whenOrNull(
        data: (_, mapObjects, __) {
          // 👈 세 번째 파라미터 `__` 추가
          if (_overlayManager != null && mapObjects != null) {
            _overlayManager!.updateOverlays(mapObjects);
          }
        },
      );
    });

    final developerIds = ref.watch(developerIdsProvider);
    final currentMemberId = ref.watch(currentMemberIdProvider);

    return NaverMap(
      options: NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(
          target: widget.initialPosition,
          zoom: 15,
        ),
        locationButtonEnable: true,
        contentPadding: EdgeInsets.only(bottom: widget.bottomPadding),
      ),
      onMapReady: (controller) {
        print("✅ [MapView] onMapReady: 지도 컨트롤러 준비 완료.");
        _mapController = controller;
        _overlayManager = MapOverlayManager(
          controller: controller,
          ref: ref,
          markerFactory: _markerFactory,
          context: context,
        );

        // 지도가 준비된 직후, 초기 데이터를 불러오도록 요청합니다.
        // WidgetsBinding.instance.addPostFrameCallback을 사용하여
        // build가 완료된 후 안전하게 상태를 변경합니다.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onCameraIdle();
        });
      },
      onCameraIdle: onCameraIdle,
      // 카메라 이동이 멈추면 데이터 요청
      // 1. 사용자가 지도를 탭했을 때 호출됩니다.
      onMapTapped: (point, latLng) {
        // '지도에 상호작용이 발생했다'는 신호를 보냅니다.
        // 이 신호를 받은 Strategy는 자신을 최소화하는 동작을 수행합니다.
        ref.read(mapSheetStrategyProvider.notifier).minimize();
      },

      // 2. 사용자가 지도를 드래그하거나 줌 하는 등 카메라가 움직일 때 호출됩니다.
      onCameraChange: (reason, animated) {
        // 카메라가 사용자의 제스처로 인해 움직였을 때,
        if (reason == NCameraUpdateReason.gesture) {
          // [핵심] 현재 바텀시트의 높이를 읽어옵니다.
          final currentSheetHeight = ref.read(mapSheetStrategyProvider).height;

          // [핵심] 바텀시트가 최소 높이(peekFraction)보다 높을 때만 minimize()를 호출합니다.
          // 이렇게 하면 불필요한 중복 호출을 완벽하게 막을 수 있습니다.
          if (currentSheetHeight > peekFraction) {
            ref.read(mapSheetStrategyProvider.notifier).minimize();
          }
        }
      },

      // 개발자용 기능: 지도를 길게 누르면 해당 위치에 글쓰기
      onMapLongTapped: (point, latLng) {
        // currentMemberId는 FutureProvider이므로, .when을 사용해 비동기 상태를 처리합니다.
        currentMemberId.whenData((id) {
          // id가 null이 아니고, developerIds 목록에 포함되어 있을 때만 기능 활성화
          if (id != null && developerIds.contains(id)) {
            showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('📍 임의 위치에 글쓰기'),
                content: Text(
                  '이 위치에 글을 작성하시겠습니까?\n\nLat: ${latLng.latitude.toStringAsFixed(5)}\nLng: ${latLng.longitude.toStringAsFixed(5)}',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('취소'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      // 다음 단계에서 구현할 내용: 좌표와 함께 글쓰기 화면으로 이동
                      context.push('/write', extra: latLng);
                    },
                    child: const Text('작성하기'),
                  ),
                ],
              ),
            );
          }
        });
      },
    );
  }

  @override
  void dispose() {
    _debounce?.cancel(); // 위젯이 제거될 때 타이머를 취소합니다.
    super.dispose();
  }

  /// 카메라 이동이 멈췄을 때 호출되는 공통 함수
  void onCameraIdle() async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (_mapController == null) return;

      // 현재 카메라 위치 정보를 가져옵니다.
      final cameraPosition = await _mapController!.getCameraPosition();
      final currentZoom = cameraPosition.zoom;
      print("📸 현재 지도 줌 레벨: $currentZoom");

      // 👇👇👇 줌 레벨 체크 로직 추가 👇👇👇
      if (currentZoom > 13) {
        // 줌 레벨이 13보다 클 때만 API를 요청합니다.
        print("➡️ [MapView] onCameraIdle: 줌 레벨이 13보다 크므로 데이터 요청을 시작합니다.");
        final bounds = await _mapController!.getContentBounds();
        ref.read(mapViewModelProvider.notifier).fetchMapObjects(bounds);
      } else {
        print("ℹ️ 줌 레벨이 13 이하이므로 API 요청을 보내지 않습니다.");
      }
    });
  }
}

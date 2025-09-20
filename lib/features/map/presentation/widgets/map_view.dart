// lib/features/map/presentation/widgets/map_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/map/presentation/manager/map_overlay_manager.dart';
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

  @override
  Widget build(BuildContext context) {
    // ref.listen을 사용하여 ViewModel의 상태 변화를 감지하고 오버레이를 업데이트합니다.
    ref.listen<MapState>(mapViewModelProvider, (previous, next) {
      // ViewModel의 상태가 'data'로 변경될 때만 오버레이를 업데이트합니다.
      next.whenOrNull(
        data: (_, mapObjects) {
          // [디버깅 로그 3] ViewModel의 데이터가 View로 전달되었는지 확인
          print(
            "✅ [MapView] ref.listen: ViewModel 데이터 수신. Objects: ${mapObjects != null}",
          );

          if (_overlayManager != null && mapObjects != null) {
            _overlayManager!.updateOverlays(mapObjects);
          }
        },
      );
    });

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
      onCameraIdle: onCameraIdle, // 카메라 이동이 멈추면 데이터 요청
    );
  }

  /// 카메라 이동이 멈췄을 때 호출되는 공통 함수
  void onCameraIdle() async {
    if (_mapController == null) return;

    // [디버깅 로그 1] 데이터 요청이 시작되는지 확인
    print("➡️ [MapView] onCameraIdle: 데이터 요청 시작.");

    final bounds = await _mapController!.getContentBounds();
    ref.read(mapViewModelProvider.notifier).fetchMapObjects(bounds);
  }
}

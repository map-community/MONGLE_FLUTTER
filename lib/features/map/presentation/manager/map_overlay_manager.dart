// lib/features/map/presentation/manager/map_overlay_manager.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:mongle_flutter/features/map/data/models/map_objects_response.dart';
import 'package:mongle_flutter/features/map/presentation/providers/map_interaction_providers.dart';
import 'package:mongle_flutter/features/map/presentation/widgets/marker_factory.dart';

// 탭된 오버레이의 종류를 명확히 구분하기 위한 Enum
enum TappedObjectType { grain, staticCloud, dynamicCloud }

/// 지도 위에 올라가는 모든 오버레이(마커, 폴리곤 등)를 관리하는 책임을 가지는 클래스입니다.
/// NaverMapController를 직접 제어하며, UI 위젯(MapView)으로부터 오버레이 관리 로직을 분리합니다.
class MapOverlayManager {
  final NaverMapController _controller;
  final WidgetRef _ref;
  final MarkerFactory _markerFactory;
  final BuildContext _context; // MarkerFactory가 위젯을 이미지로 변환할 때 필요합니다.

  MapOverlayManager({
    required NaverMapController controller,
    required WidgetRef ref,
    required MarkerFactory markerFactory,
    required BuildContext context,
  }) : _controller = controller,
       _ref = ref,
       _markerFactory = markerFactory,
       _context = context;

  /// ViewModel로부터 받은 MapObjectsResponse 데이터를 기반으로 지도 위 오버레이를 업데이트합니다.
  Future<void> updateOverlays(MapObjectsResponse? data) async {
    // 1. 기존에 그려져 있던 모든 오버레이를 삭제하여 지도를 깨끗하게 비웁니다.
    _controller.clearOverlays();

    // 2. 전달받은 데이터가 null이거나 비어있으면 아무것도 그리지 않고 종료합니다.
    if (data == null) return;

    // 3. 지도에 추가할 모든 오버레이들을 담을 Set을 준비합니다.
    final Set<NAddableOverlay> overlaysToAdd = {};

    // 4. 이슈 알갱이(grains)를 NMarker로 변환하여 Set에 추가합니다.
    for (final grain in data.grains) {
      final icon = await _markerFactory.createProfileMarkerIcon(
        context: _context,
        imageUrl: grain.profileImageUrl,
      );
      final marker = NMarker(
        id: grain.postId,
        position: NLatLng(grain.latitude, grain.longitude),
        icon: icon,
        anchor: NPoint(0.5, 1), // 마커의 기준점을 하단 중앙으로 설정
      );
      marker.setOnTapListener((_) {
        _handleTap(type: TappedObjectType.grain, id: grain.postId);
      });
      overlaysToAdd.add(marker);
    }

    // 5. 정적 클라우드(staticClouds)를 NPolygonOverlay와 NMarker로 변환하여 Set에 추가합니다.
    for (final cloud in data.staticClouds) {
      final polygon = NPolygonOverlay(
        id: cloud.placeId,
        coords: cloud.polygon,
        color: Colors.blue.withOpacity(0.2),
        outlineColor: Colors.blue,
        outlineWidth: 2,
      );

      final marker = NMarker(
        id: cloud.placeId,
        position: NLatLng(cloud.centerLatitude, cloud.centerLongitude),
        icon: NOverlayImage.fromAssetImage('assets/images/transparent_1x1.png'),
        caption: NOverlayCaption(
          text: cloud.name,
          color: Colors.blue.shade900,
          textSize: 16,
        ),
      );

      // 폴리곤과 마커 모두에 탭 리스너 추가
      polygon.setOnTapListener(
        (_) =>
            _handleTap(type: TappedObjectType.staticCloud, id: cloud.placeId),
      );
      marker.setOnTapListener(
        (_) =>
            _handleTap(type: TappedObjectType.staticCloud, id: cloud.placeId),
      );

      overlaysToAdd.add(polygon);
      overlaysToAdd.add(marker); // 수정된 마커를 추가
    }

    // 6. 동적 클라우드(dynamicClouds)를 NPolygonOverlay로 변환하여 Set에 추가합니다.
    for (final cloud in data.dynamicClouds) {
      // [수정] 폴리곤 영역 - 공식 문서에 따라 생성자에서 모든 속성을 한 번에 설정
      final polygon = NPolygonOverlay(
        id: cloud.cloudId,
        coords: cloud.polygon,
        color: Colors.purple.withOpacity(0.2),
        outlineColor: Colors.purple,
        outlineWidth: 2,
      );

      polygon.setOnTapListener(
        (_) =>
            _handleTap(type: TappedObjectType.dynamicCloud, id: cloud.cloudId),
      );
      overlaysToAdd.add(polygon);
    }

    // 7. 준비된 모든 오버레이를 addOverlayAll을 사용해 한 번에 지도에 추가합니다.
    if (overlaysToAdd.isNotEmpty) {
      _controller.addOverlayAll(overlaysToAdd);
    }
  }

  /// 탭 이벤트를 중앙에서 처리하는 헬퍼 메서드
  /// 이제 객체의 종류(type)와 순수 ID(id)를 파라미터로 받습니다.
  void _handleTap({required TappedObjectType type, required String id}) {
    final strategyNotifier = _ref.read(mapSheetStrategyProvider.notifier);

    // 탭된 객체의 종류에 따라 다른 메서드를 호출합니다.
    switch (type) {
      case TappedObjectType.grain:
        // 알갱이를 탭하면 미리보기를 보여줍니다.
        strategyNotifier.showGrainPreview(id);
        break;
      case TappedObjectType.staticCloud:
      case TappedObjectType.dynamicCloud:
        // 구름을 탭하면 전체 스레드를 보여줍니다.
        strategyNotifier.showCloudThread(id);
        break;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/community/providers/issue_grain_providers.dart';
import 'package:mongle_flutter/features/map/presentation/manager/map_overlay_manager.dart';
import 'package:mongle_flutter/features/map/presentation/providers/map_interaction_providers.dart';
import 'package:mongle_flutter/features/map/presentation/widgets/marker_factory.dart';

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
  MapOverlayManager? _overlayManager;

  @override
  Widget build(BuildContext context) {
    // 데이터가 변경되면, 매니저에게 마커 업데이트를 지시
    ref.listen(issueGrainsInCloudProvider('any_cloud_id'), (previous, next) {
      if (next is AsyncData) {
        _overlayManager?.updateMarkers(next.value!);
      }
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
        // 지도가 준비되면, 매니저와 주방장을 고용
        _overlayManager = MapOverlayManager(
          controller: controller,
          ref: ref,
          markerFactory: MarkerFactory(), // 실제로는 Provider로 주입하는 것이 더 좋음
          context: context,
        );

        // 최초 데이터로 마커를 그리도록 지시
        final initialAsyncData = ref.read(
          issueGrainsInCloudProvider('any_cloud_id'),
        );
        if (initialAsyncData is AsyncData) {
          _overlayManager?.updateMarkers(initialAsyncData.value!);
        }
      },
      onMapTapped: (point, latLng) {
        ref.read(mapSheetStrategyProvider.notifier).minimize();
      },
    );
  }
}

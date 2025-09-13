import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/map/presentation/providers/map_interaction_providers.dart';

class MapView extends ConsumerWidget {
  final NLatLng initialPosition;
  // 바텀시트 높이에 따른 동적 패딩 값을 받음
  final double bottomPadding;

  const MapView({
    super.key,
    required this.initialPosition,
    this.bottomPadding = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NaverMap(
      options: NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(
          target: initialPosition,
          zoom: 15,
        ),
        locationButtonEnable: true,
        // 바텀시트 높이만큼 지도 콘텐츠에 하단 패딩을 적용
        contentPadding: EdgeInsets.only(bottom: bottomPadding),
      ),
      // 지도 준비 완료 시 호출
      onMapReady: (controller) {
        // --- 테스트용 마커(이슈 알갱이) 추가 ---
        final marker = NMarker(
          id: 'test_marker_1',
          position: initialPosition.offsetByMeter(northMeter: 100),
        );

        // 마커 터치 시, Strategy의 showGrainPreview 메소드 호출
        marker.setOnTapListener((_) {
          ref
              .read(mapSheetStrategyProvider.notifier)
              .showGrainPreview('test_marker_1');
        });
        controller.addOverlay(marker);
      },
      // 지도 배경 터치 시, Strategy의 minimize 메소드 호출
      onMapTapped: (point, latLng) {
        ref.read(mapSheetStrategyProvider.notifier).minimize();
      },
    );
  }
}

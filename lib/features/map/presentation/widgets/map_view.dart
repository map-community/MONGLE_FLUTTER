import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/community/providers/issue_grain_providers.dart';
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
      onMapReady: (controller) async {
        // 3. Repository를 통해 모든 '알갱이' 데이터를 비동기적으로 불러옵니다.
        //    (주의: UI 상태를 계속 지켜볼 필요는 없으므로 .read를 사용합니다.)
        final grains = await ref.read(
          issueGrainsInCloudProvider('any_cloud_id').future,
        );

        // 4. 불러온 데이터 목록을 순회하며 마커를 생성합니다.
        for (final grain in grains) {
          final marker = NMarker(
            id: grain.id, // ⭐️ 고정 ID 대신 실제 데이터의 ID 사용
            position: NLatLng(
              35.890,
              128.612,
            ), // TODO: grain.latitude, grain.longitude 로 교체해야 합니다.
          );

          // 마커 터치 시, Strategy의 showGrainPreview 메소드 호출
          marker.setOnTapListener((_) {
            ref
                .read(mapSheetStrategyProvider.notifier)
                .showGrainPreview(grain.id);
          });
          controller.addOverlay(marker);
        }
      },
      // 지도 배경 터치 시, Strategy의 minimize 메소드 호출
      onMapTapped: (point, latLng) {
        ref.read(mapSheetStrategyProvider.notifier).minimize();
      },
    );
  }
}

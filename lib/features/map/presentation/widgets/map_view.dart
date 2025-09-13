import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class MapView extends StatelessWidget {
  // 1. MapScreen으로부터 지도의 초기 위치를 전달받음
  final NLatLng initialPosition;

  const MapView({super.key, required this.initialPosition});

  @override
  Widget build(BuildContext context) {
    // 2. NaverMap 위젯과 모든 설정 옵션이 이곳으로 이동
    return NaverMap(
      options: NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(
          target: initialPosition,
          zoom: 15,
        ),
        locationButtonEnable: true,
      ),
      // 여기에 마커 추가 등 지도 관련 로직을 계속해서 추가할 수 있습니다.
    );
  }
}

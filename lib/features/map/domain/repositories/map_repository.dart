import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:mongle_flutter/features/map/data/models/map_objects_response.dart';

/// 오직 지도 위에 표시될 객체들을 가져오는 책임만 가지는 Repository 계약서
abstract class MapRepository {
  /// 현재 지도 경계(bounds) 내의 모든 지도 객체(알갱이 DTO, 구름 DTO)를 가져옵니다.
  Future<MapObjectsResponse> getMapObjects(NLatLngBounds bounds);
}

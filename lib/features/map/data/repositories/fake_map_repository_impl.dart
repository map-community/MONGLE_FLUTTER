import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:mongle_flutter/features/map/data/models/map_objects_response.dart';
import 'package:mongle_flutter/features/map/data/repositories/mock_map_objects_data.dart';
import 'package:mongle_flutter/features/map/domain/repositories/map_repository.dart';

/// MapRepository의 가짜(Fake) 구현체
class FakeMapRepositoryImpl implements MapRepository {
  @override
  Future<MapObjectsResponse> getMapObjects(NLatLngBounds bounds) async {
    // API 통신을 흉내 내기 위한 가짜 딜레이
    await Future.delayed(const Duration(milliseconds: 300));

    // 미리 만들어둔 가짜 데이터를 그대로 반환합니다.
    return mockMapObjectsResponse;
  }
}

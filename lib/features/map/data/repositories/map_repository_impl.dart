import 'package:dio/dio.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:mongle_flutter/core/constants/api_constants.dart';
import 'package:mongle_flutter/features/map/data/models/map_objects_response.dart';
import 'package:mongle_flutter/features/map/domain/repositories/map_repository.dart';

// 'MapRepository' 인터페이스(계약)를 실제로 구현하는 클래스
class MapRepositoryImpl implements MapRepository {
  final Dio _dio;
  MapRepositoryImpl(this._dio);

  // TODO: [임시] 인증 기능 구현 전까지 사용할 하드코딩된 사용자 ID
  static const String _tempMemberId = "temp-user-12345";

  @override
  Future<MapObjectsResponse> getMapObjects(NLatLngBounds bounds) async {
    try {
      // dio를 사용해 GET 요청을 보냅니다.
      final response = await _dio.get(
        // 1. ApiConstants에서 경로를 가져옵니다.
        ApiConstants.mapObjects,
        // 2. 백엔드가 요구하는 파라미터들을 queryParameters에 담아 보냅니다.
        queryParameters: {
          'swLat': bounds.southWest.latitude,
          'swLng': bounds.southWest.longitude,
          'neLat': bounds.northEast.latitude,
          'neLng': bounds.northEast.longitude,
          'memberId': _tempMemberId, // 차단 필터링을 위한 임시 ID
        },
      );
      // 3. 성공 시, JSON 데이터를 MapObjectsResponse.fromJson을 통해 Dart 객체로 변환합니다.
      return MapObjectsResponse.fromJson(response.data);
    } catch (e) {
      // 4. 실패 시, 에러를 출력하고 상위로 던져 Notifier에서 처리하도록 합니다.
      print('getMapObjects Error: $e');
      rethrow;
    }
  }
}

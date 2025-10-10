import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:mongle_flutter/features/community/data/repositories/mock_issue_grain_data.dart';
import 'package:mongle_flutter/features/map/data/models/map_objects_response.dart';
import 'package:mongle_flutter/features/map/data/repositories/mock_map_objects_data.dart';
import 'package:mongle_flutter/features/map/domain/repositories/map_repository.dart';

/// MapRepository의 가짜(Fake) 구현체
class FakeMapRepositoryImpl implements MapRepository {
  @override
  Future<MapObjectsResponse> getMapObjects(NLatLngBounds bounds) async {
    // API 통신을 흉내 내기 위한 가짜 딜레이
    await Future.delayed(const Duration(milliseconds: 300));

    // [2. 수정] 공유 데이터베이스에서 최신 알갱이 목록을 읽어옵니다.
    final currentGrains = mockGrainsDatabase;

    // [3. 수정] IssueGrain 목록을 IssueGrainDto 목록으로 변환합니다.
    final grainDtos = currentGrains
        // DTO로 변환하기 전에, latitude 또는 longitude가 null인 데이터를 필터링합니다.
        .where((grain) => grain.latitude != null && grain.longitude != null)
        .map(
          (grain) => IssueGrainDto(
            postId: grain.postId,
            // 이 시점에서는 latitude와 longitude가 null이 아님이 보장되므로,
            // '!' 연산자를 사용하여 non-null 타입으로 안전하게 변환할 수 있습니다.
            latitude: grain.latitude!,
            longitude: grain.longitude!,
            author: grain.author,
          ),
        )
        .toList();

    // [4. 수정] 최신 알갱이 DTO 목록과 기존의 구름 데이터를 합쳐서 새로운 응답을 만듭니다.
    return MapObjectsResponse(
      grains: grainDtos,
      staticClouds: mockMapObjectsResponse.staticClouds, // 구름 데이터는 일단 기존 것 재사용
      dynamicClouds: mockMapObjectsResponse.dynamicClouds,
    );
  }
}

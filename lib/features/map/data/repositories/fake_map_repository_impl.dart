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
        .map(
          (grain) => IssueGrainDto(
            postId: grain.postId,
            latitude: grain.latitude,
            longitude: grain.longitude,
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

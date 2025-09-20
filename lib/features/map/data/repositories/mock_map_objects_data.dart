// lib/features/map/data/repositories/mock_map_objects_data.dart

import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:mongle_flutter/features/map/data/models/map_objects_response.dart';

/// 지도에 표시될 객체들에 대한 가짜(Mock) 데이터입니다.
/// FakeIssueGrainRepositoryImpl에서 이 데이터를 사용하여 실제 API 응답을 흉내 냅니다.
final mockMapObjectsResponse = MapObjectsResponse(
  // === 1. 이슈 알갱이 데이터 (개별 마커) ===
  grains: [
    IssueGrainDto(
      postId: 'grain_101',
      latitude: 35.8925, // 북문 근처
      longitude: 128.6095,
      profileImageUrl: 'https://i.pravatar.cc/150?u=user1',
    ),
    IssueGrainDto(
      postId: 'grain_102',
      latitude: 35.8885, // 중앙도서관 근처
      longitude: 128.6105,
      profileImageUrl: 'https://i.pravatar.cc/150?u=user2',
    ),
    IssueGrainDto(
      postId: 'grain_103',
      latitude: 35.8925, // 북문 근처
      longitude: 128.6095,
      profileImageUrl: 'https://i.pravatar.cc/150?u=user3', // 프로필 이미지가 없는 사용자
    ),
    IssueGrainDto(
      postId: 'grain_104',
      latitude: 35.8918,
      longitude: 128.6135,
      profileImageUrl: null, // 프로필 이미지가 없는 사용자
    ),
    IssueGrainDto(
      postId: 'grain_105',
      latitude: 35.8872,
      longitude: 128.6088,
      profileImageUrl: 'https://i.pravatar.cc/150?u=user5', // 프로필 이미지가 없는 사용자
    ),
  ],
  // === 2. 정적 클라우드 데이터 (폴리곤 + 중심 마커) ===
  staticClouds: [
    StaticCloudDto(
      placeId: 'static_cloud_1',
      name: "IT 5호관",
      centerLatitude: 35.888114,
      centerLongitude: 128.61146,
      postCount: 42,
      polygon: [
        NLatLng(35.88831036130315, 128.61114075356852),
        NLatLng(35.887956, 128.61116),
        NLatLng(35.887950, 128.611941),
        NLatLng(35.8881104, 128.61193),
        NLatLng(35.88811, 128.61174),
        NLatLng(35.888247, 128.611762),
        NLatLng(35.88831036130315, 128.61114075356852), // 닫는 점 (시작점과 동일)
      ],
    ),
    StaticCloudDto(
      placeId: 'static_cloud_2',
      name: "중앙도서관 구관",
      centerLatitude: 35.891724,
      centerLongitude: 128.612104,
      postCount: 42,
      polygon: [
        NLatLng(35.8920605, 128.61170),
        NLatLng(35.891382, 128.611665),
        NLatLng(35.89134, 128.612448),
        NLatLng(35.8916785, 128.61247),
        NLatLng(35.8916674, 128.612623),

        NLatLng(35.8917327, 128.612624),
        NLatLng(35.891743, 128.612470),
        NLatLng(35.892047, 128.6124872),

        NLatLng(35.8920605, 128.61170), // 닫는 점 (시작점과 동일)
      ],
    ),
    StaticCloudDto(
      placeId: 'static_3',
      name: "중앙도서관 신관",
      centerLatitude: 35.891910,
      centerLongitude: 128.612661,
      postCount: 210,
      polygon: [
        NLatLng(35.8921688, 128.61253),
        NLatLng(35.89213, 128.612829),
        NLatLng(35.891716669, 128.61281),
        NLatLng(35.8917327, 128.612624),
        NLatLng(35.891743, 128.612470),
        NLatLng(35.892047, 128.6124872),
        NLatLng(35.892054, 128.612523),
        NLatLng(35.8921688, 128.61253), // 닫는 점 (시작점과 동일)
      ],
    ),
  ],
  // === 3. 동적 클라우드 데이터 (폴리곤) ===
  dynamicClouds: [
    DynamicCloudDto(
      cloudId: 'dynamic_cloud_21',
      postCount: 15,
      polygon: [
        NLatLng(35.8900, 128.6120),
        NLatLng(35.8910, 128.6125),
        NLatLng(35.8905, 128.6135),
        NLatLng(35.8895, 128.6130),
        NLatLng(35.8900, 128.6120), // 닫는 점 (시작점과 동일)
      ],
    ),
  ],
);

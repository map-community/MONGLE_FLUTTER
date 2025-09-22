import 'package:mongle_flutter/features/community/domain/entities/author.dart';

import 'package:mongle_flutter/features/community/domain/entities/author.dart';
import 'package:mongle_flutter/features/community/domain/entities/issue_grain.dart';

// ⭐️ 프로필 이미지가 없는 목업 유저
const _author4 = Author(
  id: 'user4',
  nickname: '조용한 몽글러',
  profileImageUrl: null, // 이미지가 없음
);

// 목업 데이터를 별도의 파일로 분리하여 관리합니다.
final List<IssueGrain> mockIssueGrains = [
  IssueGrain(
    // ⭐️ id -> postId로 필드명 변경
    postId: 'grain_101',
    author: const Author(
      id: 'user1',
      nickname: '익명의 몽글러1',
      profileImageUrl: 'https://i.pravatar.cc/150?u=user1',
    ),
    content: 'IT 5호관 1층 프린터에 A4용지 채워져 있나요? 사진까지 찍어주시면 사례할게요!',
    // ⭐️ 위도(latitude), 경도(longitude) 필드 추가
    latitude: 35.8860, // IT-1호관 근처
    longitude: 128.6090,
    photoUrls: [
      'https://picsum.photos/seed/grain1_1/400/300',
      'https://picsum.photos/seed/grain1_2/400/300',
    ],
    // ⭐️ created_at -> createdAt으로 필드명 변경 (Entity에 맞춰)
    createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    viewCount: 152,
    likeCount: 22,
    dislikeCount: 1,
    commentCount: 5,
  ),
  IssueGrain(
    postId: 'grain_102',
    author: const Author(
      id: 'user2',
      nickname: '센팍 지박령',
      profileImageUrl: 'https://i.pravatar.cc/150?u=user2',
    ),
    content: '지금 중앙도서관 3층 열람실 자리 널널한 편인가요? 사람 너무 많으면 가기 싫어서...',
    latitude: 35.8885, // 중앙도서관 근처
    longitude: 128.6105,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    viewCount: 89,
    likeCount: 12,
    dislikeCount: 0,
    commentCount: 3,
  ),
  IssueGrain(
    postId: 'grain_103',
    author: const Author(
      id: 'user3',
      nickname: '북문 매니아',
      profileImageUrl: 'https://i.pravatar.cc/150?u=user3',
    ),
    content: '북문에 새로 생긴 와플 트럭 아직도 있나요? 혹시 줄 긴가요?',
    latitude: 35.8925, // 북문 근처
    longitude: 128.6095,
    photoUrls: ['https://picsum.photos/seed/grain3_1/400/300'],
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    viewCount: 312,
    likeCount: 45,
    dislikeCount: 3,
    commentCount: 12,
  ),
  IssueGrain(
    postId: 'grain_104',
    author: _author4, // 프로필 사진 없는 유저
    content: '글로벌 라운지 지금 문 열었나요?',
    latitude: 35.8918,
    longitude: 128.6135,
    createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    viewCount: 21,
    likeCount: 2,
    dislikeCount: 0,
    commentCount: 1,
  ),
  IssueGrain(
    postId: 'grain_105',
    author: const Author(
      id: 'user5',
      nickname: '공대생',
      profileImageUrl: 'https://i.pravatar.cc/150?u=user5',
    ),
    content:
        '공대 9호관 1층에 택배 맡길 곳 있나요? 잠깐만 맡아주실 분공대 9호관 1층에 택배 맡길 곳 있나요? 잠깐만 맡아주실 분공대 9호관 1층에 택배 맡길 곳 있나요? 잠깐만 맡아주실 분공대 9호관 1층에 택배 맡길 곳 있나요? 잠깐만 맡아주실 분공대 9호관 1층에 택배 맡길 곳 있나요? 잠깐만 맡아주실 분',
    latitude: 35.8872,
    longitude: 128.6088,
    createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
    viewCount: 78,
    likeCount: 8,
    dislikeCount: 0,
    commentCount: 2,
  ),
];

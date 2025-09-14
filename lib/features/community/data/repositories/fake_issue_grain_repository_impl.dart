import 'package:mongle_flutter/features/community/domain/entities/author.dart';
import 'package:mongle_flutter/features/community/domain/entities/issue_grain.dart';
import 'package:mongle_flutter/features/community/domain/repositories/issue_grain_repository.dart';

class FakeIssueGrainRepositoryImpl implements IssueGrainRepository {
  // 테스트를 위한 메모리 내 가짜 데이터베이스
  final List<IssueGrain> _mockData = [
    IssueGrain(
      id: 'grain1',
      author: const Author(
        id: 'user1',
        nickname: '익명의 몽글러1',
        profileImageUrl: 'https://i.pravatar.cc/150?u=user1',
      ),
      content: 'IT 5호관 1층 프린터에 A4용지 채워져 있나요? 사진까지 찍어주시면 사례할게요!',
      photoUrls: [
        'https://source.unsplash.com/random/1',
        'https://source.unsplash.com/random/2',
      ],
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      viewCount: 152,
      likeCount: 22,
      dislikeCount: 1,
      commentCount: 5,
    ),
    IssueGrain(
      id: 'grain2',
      author: const Author(
        id: 'user2',
        nickname: '센팍 지박령',
        profileImageUrl: 'https://i.pravatar.cc/150?u=user2',
      ),
      content: '지금 중앙도서관 3층 열람실 자리 널널한 편인가요? 사람 너무 많으면 가기 싫어서...',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      viewCount: 89,
      likeCount: 12,
      dislikeCount: 0,
      commentCount: 3,
    ),
  ];

  @override
  Future<List<IssueGrain>> getIssueGrainsInCloud(String cloudId) async {
    await Future.delayed(const Duration(milliseconds: 300)); // API 딜레이 흉내
    return _mockData;
  }

  @override
  Future<IssueGrain> getIssueGrainById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockData.firstWhere((grain) => grain.id == id);
  }

  @override
  Future<void> likeIssueGrain(String id) async {
    print("API 요청: $id 게시물 좋아요");
    await Future.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<void> dislikeIssueGrain(String id) async {
    print("API 요청: $id 게시물 싫어요");
    await Future.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<void> incrementViewCount(String id) async {
    print("API 요청: $id 게시물 조회수 증가");
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

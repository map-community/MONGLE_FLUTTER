import 'package:mongle_flutter/features/community/data/repositories/mock_cloud_contents_data.dart';
import 'package:mongle_flutter/features/community/data/repositories/mock_issue_grain_data.dart';
import 'package:mongle_flutter/features/community/domain/entities/author.dart';
import 'package:mongle_flutter/features/community/domain/entities/issue_grain.dart';
import 'package:mongle_flutter/features/community/domain/repositories/issue_grain_repository.dart';

class FakeIssueGrainRepositoryImpl implements IssueGrainRepository {
  // 테스트를 위한 메모리 내 가짜 데이터베이스
  final List<IssueGrain> _allGrainsDb = List.from(mockIssueGrains);

  @override
  Future<List<IssueGrain>> getIssueGrainsInCloud(String cloudId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // 1. mockCloudContents 맵에서 cloudId에 해당하는 postId 리스트를 찾습니다.
    final postIdsInCloud = mockCloudContents[cloudId];

    // 2. 만약 해당하는 postId 리스트가 없으면, 빈 리스트를 반환합니다.
    if (postIdsInCloud == null) {
      return [];
    }

    // 3. 전체 알갱이 목록(_allGrainsDb)에서, 필요한 postId를 가진 알갱이들만 필터링합니다.
    final result = _allGrainsDb
        .where((grain) => postIdsInCloud.contains(grain.postId))
        .toList();

    return result;
  }

  @override
  Future<IssueGrain> getIssueGrainById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _allGrainsDb.firstWhere((grain) => grain.postId == id);
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

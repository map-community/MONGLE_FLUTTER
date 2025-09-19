import 'package:mongle_flutter/features/community/data/repositories/mock_issue_grain_data.dart';
import 'package:mongle_flutter/features/community/domain/entities/author.dart';
import 'package:mongle_flutter/features/community/domain/entities/issue_grain.dart';
import 'package:mongle_flutter/features/community/domain/repositories/issue_grain_repository.dart';

class FakeIssueGrainRepositoryImpl implements IssueGrainRepository {
  // 테스트를 위한 메모리 내 가짜 데이터베이스
  final List<IssueGrain> _db = List.from(mockIssueGrains);

  @override
  Future<List<IssueGrain>> getIssueGrainsInCloud(String cloudId) async {
    await Future.delayed(const Duration(milliseconds: 300)); // API 딜레이 흉내
    return _db;
  }

  @override
  Future<IssueGrain> getIssueGrainById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _db.firstWhere((grain) => grain.postId == id);
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

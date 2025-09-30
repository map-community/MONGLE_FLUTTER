import 'package:mongle_flutter/features/community/data/repositories/mock_cloud_contents_data.dart';
import 'package:mongle_flutter/features/community/data/repositories/mock_comment_data.dart';
import 'package:mongle_flutter/features/community/data/repositories/mock_issue_grain_data.dart';
import 'package:mongle_flutter/features/community/domain/entities/author.dart';
import 'package:mongle_flutter/features/community/domain/entities/issue_grain.dart';
import 'package:mongle_flutter/features/community/domain/repositories/issue_grain_repository.dart';

class FakeIssueGrainRepositoryImpl implements IssueGrainRepository {
  // [수정] 복사본을 만드는 대신, 공유 데이터베이스를 직접 사용합니다.
  final List<IssueGrain> _db = mockGrainsDatabase;

  @override
  Future<IssueGrain> createIssueGrain({
    required String content,
    required List<String> photoUrls,
    required double latitude,
    required double longitude,
  }) async {
    // [2] 실제 서버와 통신하는 것처럼 0.5초 딜레이를 줍니다.
    await Future.delayed(const Duration(milliseconds: 500));

    // [3] 새로운 IssueGrain 객체를 생성합니다.
    final newGrain = IssueGrain(
      // postId는 보통 서버에서 생성해주므로, 임시로 고유한 값을 만들어줍니다.
      postId: 'grain_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      photoUrls: photoUrls,
      latitude: latitude,
      longitude: longitude,
      // 현재 로그인한 사용자는 임시로 mockCurrentUser를 사용합니다.
      author: mockCurrentUser,
      createdAt: DateTime.now(),
      // 새 글이므로 모든 카운트는 0으로 시작합니다.
      viewCount: 0,
      likeCount: 0,
      dislikeCount: 0,
      commentCount: 0,
    );

    // [4] 가짜 데이터베이스(리스트)의 맨 앞에 새로운 게시글을 추가합니다.
    _db.insert(0, newGrain);

    print('✅ [FakeRepo] 새 알갱이 생성됨: ${newGrain.postId}');

    // [5] 생성된 객체를 반환합니다.
    return newGrain;
  }

  @override
  Future<List<IssueGrain>> getIssueGrainsInCloud(String cloudId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // 1. mockCloudContents 맵에서 cloudId에 해당하는 postId 리스트를 찾습니다.
    final postIdsInCloud = mockCloudContents[cloudId];

    // 2. 만약 해당하는 postId 리스트가 없으면, 빈 리스트를 반환합니다.
    if (postIdsInCloud == null) {
      return [];
    }

    // 3. 전체 알갱이 목록(_db)에서, 필요한 postId를 가진 알갱이들만 필터링합니다.
    final result = _db
        .where((grain) => postIdsInCloud.contains(grain.postId))
        .toList();

    return result;
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

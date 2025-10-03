// lib/features/community/data/repositories/fake_issue_grain_repository_impl.dart

import 'package:mongle_flutter/features/community/data/repositories/mock_cloud_contents_data.dart';
import 'package:mongle_flutter/features/community/data/repositories/mock_comment_data.dart';
import 'package:mongle_flutter/features/community/data/repositories/mock_issue_grain_data.dart';
import 'package:mongle_flutter/features/community/domain/entities/issue_grain.dart';
import 'package:mongle_flutter/features/community/domain/repositories/issue_grain_repository.dart';

class FakeIssueGrainRepositoryImpl implements IssueGrainRepository {
  final List<IssueGrain> _db = mockGrainsDatabase;

  // --- 🔽 기존 createIssueGrain 함수는 삭제하고 아래 3개 함수를 새로 구현합니다. 🔽 ---

  @override
  Future<void> createPost({
    required String content,
    required double latitude,
    required double longitude,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newGrain = IssueGrain(
      postId: 'grain_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      photoUrls: [],
      latitude: latitude,
      longitude: longitude,
      author: mockCurrentUser,
      createdAt: DateTime.now(),
      viewCount: 0,
      likeCount: 0,
      dislikeCount: 0,
      commentCount: 0,
    );
    _db.insert(0, newGrain);
    print('✅ [FakeRepo] 새 알갱이 생성됨 (텍스트 전용): ${newGrain.postId}');
  }

  @override
  Future<List<IssuedUrlInfo>> requestUploadUrls({
    required List<UploadFileInfo> files,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    print('✅ [FakeRepo] ${files.length}개 파일에 대한 Presigned URL 요청 받음');

    final fakeUrls = files.map((fileInfo) {
      final fakeFileKey =
          'uploads/${DateTime.now().millisecondsSinceEpoch}-${fileInfo.fileName}';
      final fakeUrl =
          'https://s3.fake-region.amazonaws.com/fake-bucket/$fakeFileKey?signature=fake_signature';

      return IssuedUrlInfo(
        fileKey: fakeFileKey,
        presignedUrl: fakeUrl,
        expiresAt: DateTime.now()
            .add(const Duration(minutes: 15))
            .toIso8601String(),
      );
    }).toList();
    return fakeUrls;
  }

  @override
  Future<void> completePostCreation({
    required String content,
    required List<String> fileKeyList,
    required double latitude,
    required double longitude,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // [수정] fileKeyList를 가짜 전체 URL 목록으로 변환합니다.
    final fakeFullUrls = fileKeyList
        .map((key) => 'https://s3.fake-region.amazonaws.com/fake-bucket/$key')
        .toList();

    final newGrain = IssueGrain(
      postId: 'grain_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      photoUrls: fakeFullUrls, // [수정] 변환된 URL 목록을 photoUrls에 저장
      latitude: latitude,
      longitude: longitude,
      author: mockCurrentUser,
      createdAt: DateTime.now(),
      viewCount: 0,
      likeCount: 0,
      dislikeCount: 0,
      commentCount: 0,
    );

    _db.insert(0, newGrain);
    print('✅ [FakeRepo] 새 알갱이 생성 완료 (파일 포함): ${newGrain.postId}');
  }

  // --- 🔽 아래 함수들은 기존과 동일합니다. 🔽 ---

  @override
  Future<List<IssueGrain>> getIssueGrainsInCloud(String cloudId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final postIdsInCloud = mockCloudContents[cloudId];
    if (postIdsInCloud == null) {
      return [];
    }
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

// lib/features/community/repositories/issue_grain_repository.dart

import 'package:mongle_flutter/features/community/domain/entities/issue_grain.dart';
import 'package:mongle_flutter/features/community/providers/write_grain_providers.dart';

// -----------------------------------------------------------------------------
// 데이터 모델 (Data Models)
// -----------------------------------------------------------------------------

/// Presigned URL을 요청할 때 백엔드로 보낼 파일 1개의 정보를 담는 데이터 클래스입니다.
class UploadFileInfo {
  final String fileName;
  final int fileSize;

  UploadFileInfo({required this.fileName, required this.fileSize});

  Map<String, dynamic> toJson() {
    return {'fileName': fileName, 'fileSize': fileSize};
  }
}

/// 서버로부터 받은 Presigned URL 정보를 담는 데이터 모델입니다.
class IssuedUrlInfo {
  final String fileKey;
  final String presignedUrl;
  final String expiresAt;

  IssuedUrlInfo({
    required this.fileKey,
    required this.presignedUrl,
    required this.expiresAt,
  });

  factory IssuedUrlInfo.fromJson(Map<String, dynamic> json) {
    return IssuedUrlInfo(
      fileKey: json['fileKey'],
      presignedUrl: json['presignedUrl'],
      expiresAt: json['expiresAt'],
    );
  }
}

// -----------------------------------------------------------------------------
// Repository 추상 클래스 (The Contract)
// -----------------------------------------------------------------------------

/// '이슈 알갱이' 데이터 통신을 위한 계약서(추상 클래스)입니다.
/// 이 Repository를 구현하는 모든 클래스는 아래에 정의된 함수들을 반드시 가지고 있어야 합니다.
abstract class IssueGrainRepository {
  // --- 글쓰기 관련 함수 (새로운 Presigned URL 방식 적용) ---

  /// 1. (파일이 없을 때) 텍스트만 있는 게시글을 생성합니다.
  Future<void> createPost({
    required String content,
    required double latitude,
    required double longitude,
  });

  /// 2. (파일이 있을 때 Step 1) 파일 업로드를 위한 Presigned URL들을 서버에 요청합니다.
  Future<List<IssuedUrlInfo>> requestUploadUrls({
    required List<UploadFileInfo> files,
  });

  /// 3. (파일이 있을 때 Step 3) 파일 업로드 완료 후, 최종적으로 게시글 생성을 완료합니다.
  Future<void> completePostCreation({
    required String content,
    required List<String> fileKeyList,
    required double latitude,
    required double longitude,
  });

  // --- 글 읽기 및 상호작용 관련 함수 (기존과 동일) ---

  ///  정적 구름의 게시물 목록을 가져오는 메서드
  Future<List<IssueGrain>> getGrainsInStaticCloud(String placeId);

  /// 동적 구름의 게시물 목록을 가져오는 메서드
  Future<List<IssueGrain>> getGrainsInDynamicCloud(String cloudId);

  /// 고유 ID를 통해 단일 이슈 알갱이 정보를 가져옵니다.
  Future<IssueGrain> getIssueGrainById(String id);

  /// 이슈 알갱이에 대한 좋아요를 요청합니다.
  Future<void> likeIssueGrain(String id);

  /// 이슈 알갱이에 대한 싫어요를 요청합니다.
  Future<void> dislikeIssueGrain(String id);
}

import 'package:dio/dio.dart';
import 'package:mongle_flutter/features/community/domain/entities/issue_grain.dart';
import 'package:mongle_flutter/features/community/domain/repositories/issue_grain_repository.dart';
import 'package:mongle_flutter/features/community/providers/write_grain_providers.dart';

/// IssueGrainRepository의 실제 구현 클래스입니다.
/// Dio를 사용하여 실제 백엔드 API 서버와 통신하는 로직을 담당합니다.
class IssueGrainRepositoryImpl implements IssueGrainRepository {
  final Dio _dio;

  IssueGrainRepositoryImpl(this._dio);

  // --- 글쓰기 관련 함수 (새로운 Presigned URL 방식 적용) ---

  @override
  Future<void> createPost({
    required String content,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _dio.post(
        '/posts', // 텍스트 전용 게시글 생성 API 엔드포인트
        data: {
          'content': content,
          'latitude': latitude,
          'longitude': longitude,
        },
      );
    } catch (e) {
      // 실제 앱에서는 사용자에게 보여줄 수 있는 커스텀 에러로 변환하는 것이 좋습니다.
      print('createPost Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<IssuedUrlInfo>> requestUploadUrls({
    required List<UploadFileInfo> files,
  }) async {
    try {
      final response = await _dio.post(
        '/posts/presigned-urls', // Presigned URL 요청 API 엔드포인트
        data: {'files': files.map((fileInfo) => fileInfo.toJson()).toList()},
      );

      return (response.data['issuedUrls'] as List)
          .map((item) => IssuedUrlInfo.fromJson(item))
          .toList();
    } catch (e) {
      print('requestUploadUrls Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> completePostCreation({
    required String content,
    required List<String> fileKeyList, // 👈 이렇게 단일 리스트로 변경
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _dio.post(
        '/posts/complete',
        data: {
          'content': content,
          'fileKeyList': fileKeyList, // 👈 서버로 보낼 때도 단일 키로 전송
          'latitude': latitude,
          'longitude': longitude,
        },
      );
    } catch (e) {
      print('completePostCreation Error: $e');
      rethrow;
    }
  }

  // --- 글 읽기 및 상호작용 관련 함수 ---

  @override
  Future<List<IssueGrain>> getIssueGrainsInCloud(String cloudId) async {
    // TODO: 백엔드 API가 준비되면 실제 엔드포인트와 데이터 파싱 로직을 구현해야 합니다.
    try {
      // 예시: final response = await _dio.get('/clouds/$cloudId/grains');
      // return (response.data as List).map((item) => IssueGrain.fromJson(item)).toList();
      print('getIssueGrainsInCloud for $cloudId called');
      await Future.delayed(const Duration(seconds: 1)); // 가짜 딜레이
      return []; // 임시로 빈 리스트 반환
    } catch (e) {
      print('getIssueGrainsInCloud Error: $e');
      rethrow;
    }
  }

  @override
  Future<IssueGrain> getIssueGrainById(String id) async {
    // TODO: 백엔드 API가 준비되면 실제 엔드포인트와 데이터 파싱 로직을 구현해야 합니다.
    try {
      // 예시: final response = await _dio.get('/grains/$id');
      // return IssueGrain.fromJson(response.data);
      print('getIssueGrainById for $id called');
      await Future.delayed(const Duration(seconds: 1));
      // 임시로 비어있는 IssueGrain 객체 반환 (실제로는 에러 처리 필요)
      throw UnimplementedError('getIssueGrainById is not implemented yet');
    } catch (e) {
      print('getIssueGrainById Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> likeIssueGrain(String id) async {
    // TODO: 백엔드 API가 준비되면 실제 엔드포인트와 로직을 구현해야 합니다.
    try {
      // 예시: await _dio.post('/grains/$id/like');
      print('likeIssueGrain for $id called');
    } catch (e) {
      print('likeIssueGrain Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> dislikeIssueGrain(String id) async {
    // TODO: 백엔드 API가 준비되면 실제 엔드포인트와 로직을 구현해야 합니다.
    try {
      // 예시: await _dio.post('/grains/$id/dislike');
      print('dislikeIssueGrain for $id called');
    } catch (e) {
      print('dislikeIssueGrain Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> incrementViewCount(String id) async {
    // TODO: 백엔드 API가 준비되면 실제 엔드포인트와 로직을 구현해야 합니다.
    try {
      // 예시: await _dio.post('/grains/$id/view');
      print('incrementViewCount for $id called');
    } catch (e) {
      print('incrementViewCount Error: $e');
      rethrow;
    }
  }
}

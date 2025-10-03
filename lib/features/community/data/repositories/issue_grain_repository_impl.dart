import 'package:dio/dio.dart';
import 'package:mongle_flutter/core/constants/api_constants.dart';
import 'package:mongle_flutter/core/dio/dio_provider.dart'; // Dio Provider를 사용하기 위해 import
import 'package:mongle_flutter/core/errors/exceptions.dart';
import 'package:mongle_flutter/features/auth/data/data_sources/token_storage_service.dart';
import 'package:mongle_flutter/features/community/domain/entities/issue_grain.dart';
import 'package:mongle_flutter/features/community/domain/repositories/issue_grain_repository.dart';
import 'dart:convert'; // 👈 디코딩을 위해 dart:convert 라이브러리를 import 합니다.

/// 'IssueGrainRepository' 인터페이스의 실제 구현 클래스입니다.
/// Dio를 사용하여 실제 백엔드 API 서버와 통신하는 로직을 담당합니다.
class IssueGrainRepositoryImpl implements IssueGrainRepository {
  // 서버와 통신하기 위한 Dio 인스턴스.
  // 외부에서 생성된 것을 전달받아 사용합니다(Dependency Injection).
  final Dio _dio;
  final TokenStorageService _tokenStorage; // 👈 _tokenStorage 필드 추가

  // 생성자: 이 클래스가 생성될 때 반드시 Dio 인스턴스를 전달받아야 합니다.
  IssueGrainRepositoryImpl(this._dio, this._tokenStorage);

  // ✅ [임시 수정] 백엔드 title 필드(@NotBlank) 대응을 위한 임시 제목
  static const String _tempTitle = "임시 제목";

  // 👇 [추가] JWT 토큰에서 memberId(sub)를 추출하는 임시 비공개 함수
  Future<String?> _getMemberIdFromToken() async {
    // 1. 저장소에서 AccessToken을 가져옵니다.
    final token = await _tokenStorage.getAccessToken();
    if (token == null) return null;

    try {
      // 2. 토큰을 '.' 기준으로 세 부분으로 나눕니다.
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // 3. 두 번째 부분(Payload)을 디코딩합니다.
      final payload = parts[1];
      final normalized = base64Url.normalize(payload); // Base64Url 포맷에 맞게 패딩 처리
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded) as Map<String, dynamic>;

      // 4. 디코딩된 JSON에서 'sub' 값을 찾아 반환합니다.
      return payloadMap['sub'] as String?;
    } catch (e) {
      // 디코딩 중 에러 발생 시 null을 반환합니다.
      print('임시 토큰 디코딩 에러: $e');
      return null;
    }
  }

  // --- 글쓰기 관련 함수 (실제 API 호출) ---

  @override
  Future<void> createPost({
    required String content,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final memberId = await _getMemberIdFromToken();
      if (memberId == null) {
        throw ApiException('사용자 인증 정보를 찾을 수 없습니다. 다시 로그인해주세요.');
      }

      // POST /api/v1/posts 엔드포인트에 데이터를 전송합니다.
      await _dio.post(
        ApiConstants.posts,
        data: {
          'title': _tempTitle, // ✅ [임시 수정] title 필드 추가
          'content': content,
          'latitude': latitude,
          'longitude': longitude,
          // [핵심] 이슈 티켓에 따라 임시 authorId를 body에 포함합니다.
          'authorId': memberId,
        },
      );
    } catch (e) {
      // 실제 앱에서는 사용자에게 보여줄 수 있는 커스텀 에러로 변환하는 것이 좋습니다.
      print('createPost Error: $e');
      rethrow; // 에러를 다시 던져서 상위 로직(Notifier)에서 처리할 수 있게 합니다.
    }
  }

  @override
  Future<List<IssuedUrlInfo>> requestUploadUrls({
    required List<UploadFileInfo> files,
  }) async {
    try {
      // POST /api/v1/post-files/upload-urls 엔드포인트에 파일 목록을 전송합니다.
      final response = await _dio.post(
        ApiConstants.postFileUploadUrls,
        data: {'files': files.map((fileInfo) => fileInfo.toJson()).toList()},
      );
      // 서버 응답(JSON)을 List<IssuedUrlInfo> 객체로 변환하여 반환합니다.
      return (response.data['issuedUrls'] as List)
          .map((item) => IssuedUrlInfo.fromJson(item))
          .toList();
    } catch (e) {
      print('requestUploadUrls Error: $e');
      rethrow;
    }
  }

  // 파일이 있는 경우에도 동일한 ApiConstants.posts 엔드포인트를 사용합니다.
  @override
  Future<void> completePostCreation({
    required String content,
    required List<String> fileKeyList,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final memberId = await _getMemberIdFromToken();
      if (memberId == null) {
        throw ApiException('사용자 인증 정보를 찾을 수 없습니다. 다시 로그인해주세요.');
      }

      // POST /api/v1/posts/complete 엔드포인트에 데이터를 전송합니다.
      await _dio.post(
        ApiConstants.posts,
        data: {
          'title': _tempTitle, // ✅ [임시 수정] title 필드 추가
          'content': content,
          'fileKeyList': fileKeyList,
          'latitude': latitude,
          'longitude': longitude,
          // [핵심] 이슈 티켓에 따라 임시 authorId를 body에 포함합니다.
          'authorId': memberId,
        },
      );
    } catch (e) {
      print('completePostCreation Error: $e');
      rethrow;
    }
  }

  // --- 글 읽기 및 상호작용 관련 함수 (아직 구현하지 않음) ---
  // 이 부분들은 지금 당장 필요 없으므로, 나중에 구현할 수 있도록 비워둡니다.

  @override
  Future<List<IssueGrain>> getIssueGrainsInCloud(String cloudId) async {
    // TODO: 백엔드 API가 준비되면 실제 엔드포인트와 데이터 파싱 로직을 구현해야 합니다.
    throw UnimplementedError('getIssueGrainsInCloud is not implemented yet');
  }

  @override
  Future<IssueGrain> getIssueGrainById(String id) async {
    try {
      // 1. 1단계에서 만든 ApiConstants 함수를 사용해 GET 요청을 보냅니다.
      final response = await _dio.get(ApiConstants.postById(id));

      // 2. ApiInterceptor 덕분에 response.data는 순수한 JSON 객체입니다.
      //    2단계에서 수정한 IssueGrain.fromJson을 통해 Dart 객체로 변환 후 반환합니다.
      return IssueGrain.fromJson(response.data);
    } catch (e) {
      // 3. Dio에서 에러가 발생하면 (ApiInterceptor가 가공한 후)
      //    그대로 다시 던져서 Notifier가 처리하도록 합니다.
      rethrow;
    }
  }

  @override
  Future<void> likeIssueGrain(String id) async {
    // TODO: 백엔드 API가 준비되면 실제 엔드포인트와 로직을 구현해야 합니다.
    throw UnimplementedError('likeIssueGrain is not implemented yet');
  }

  @override
  Future<void> dislikeIssueGrain(String id) async {
    // TODO: 백엔드 API가 준비되면 실제 엔드포인트와 로직을 구현해야 합니다.
    throw UnimplementedError('dislikeIssueGrain is not implemented yet');
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:mongle_flutter/core/constants/api_constants.dart';
import 'package:mongle_flutter/core/dio/dio_provider.dart'; // Dio Provider를 사용하기 위해 import
import 'package:mongle_flutter/core/errors/exceptions.dart';
import 'package:mongle_flutter/features/auth/data/data_sources/token_storage_service.dart';
import 'package:mongle_flutter/features/community/domain/entities/issue_grain.dart';
import 'package:mongle_flutter/features/community/domain/entities/paginated_posts.dart';
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

  // JWT 토큰에서 memberId(sub)를 추출하는 임시 비공개 함수
  Future<String> _getRequiredMemberId() async {
    final token = await _tokenStorage.getAccessToken();

    // 1. 토큰이 없는 경우, 명확한 에러 메시지를 던집니다.
    if (token == null) {
      throw ApiException('로그인이 필요합니다. 다시 로그인해주세요.');
    }

    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        // 2. 토큰 형식이 잘못된 경우의 에러 처리
        throw ApiException('인증 정보가 올바르지 않습니다. (Malformed Token)');
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded) as Map<String, dynamic>;
      final memberId = payloadMap['sub'] as String?;

      if (memberId == null) {
        // 3. 토큰 안에 'sub' 클레임이 없는 경우의 에러 처리
        throw ApiException('인증 정보가 올바르지 않습니다. (No Subject)');
      }

      return memberId;
    } catch (e) {
      // 4. 그 외 모든 디코딩 관련 에러 처리
      print('토큰 디코딩 실패: $e');
      throw ApiException('인증 정보를 처리하는 중 오류가 발생했습니다.');
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
      // POST /api/v1/posts 엔드포인트에 데이터를 전송합니다.
      await _dio.post(
        ApiConstants.posts,
        data: {
          'content': content,
          'latitude': latitude,
          'longitude': longitude,
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
      // POST /api/v1/posts/complete 엔드포인트에 데이터를 전송합니다.
      await _dio.post(
        ApiConstants.posts,
        data: {
          'content': content,
          'fileKeyList': fileKeyList,
          'latitude': latitude,
          'longitude': longitude,
        },
      );
    } catch (e) {
      print('completePostCreation Error: $e');
      rethrow;
    }
  }

  // --- 글 읽기 및 상호작용 관련 함수  ---
  Future<PaginatedPosts> _getGrainsInCloud(
    Map<String, dynamic> queryParameters,
  ) async {
    try {
      final response = await _dio.get(
        ApiConstants.posts,
        queryParameters: queryParameters,
      );
      // ✅ [수정] 응답 전체를 PaginatedPosts.fromJson으로 파싱합니다.
      return PaginatedPosts.fromJson(response.data);
    } catch (e) {
      print('Error fetching grains in cloud: $e');
      rethrow;
    }
  }

  @override
  Future<PaginatedPosts> getGrainsInStaticCloud({
    required String placeId,
    String? cursor,
  }) async {
    final memberId = await _getRequiredMemberId();
    // 백엔드 명세에 맞는 쿼리 파라미터를 설정합니다.
    final params = {
      'placeId': placeId,
      'cursor': cursor, // cursor 파라미터 추가
      'memberId': memberId,
    };
    // 공통 헬퍼 메서드를 호출하여 작업을 위임합니다.
    return _getGrainsInCloud(params);
  }

  @override
  Future<PaginatedPosts> getGrainsInDynamicCloud({
    required String cloudId,
    String? cursor,
  }) async {
    final memberId = await _getRequiredMemberId();

    // 백엔드 명세에 맞는 쿼리 파라미터를 설정합니다.
    final params = {
      'cloudId': cloudId,
      'cursor': cursor, // cursor 파라미터 추가
      'memberId': memberId,
    };
    // 공통 헬퍼 메서드를 호출하여 작업을 위임합니다.
    return _getGrainsInCloud(params);
  }

  @override
  Future<PaginatedPosts> getNearbyGrains(NLatLngBounds bounds) async {
    try {
      final response = await _dio.get(
        ApiConstants.posts,
        queryParameters: {
          'swLat': bounds.southWest.latitude,
          'swLng': bounds.southWest.longitude,
          'neLat': bounds.northEast.latitude,
          'neLng': bounds.northEast.longitude,
          // size, cursor 등 페이지네이션 파라미터도 추가 가능
        },
      );
      // MapObjectsResponse가 아닌 PaginatedPosts로 파싱
      return PaginatedPosts.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
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

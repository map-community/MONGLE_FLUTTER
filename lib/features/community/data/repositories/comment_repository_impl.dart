import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:mongle_flutter/core/constants/api_constants.dart';
import 'package:mongle_flutter/core/errors/exceptions.dart';
import 'package:mongle_flutter/features/auth/data/data_sources/token_storage_service.dart';
import 'package:mongle_flutter/features/community/domain/entities/author.dart';
import 'package:mongle_flutter/features/community/domain/entities/comment.dart';
import 'package:mongle_flutter/features/community/domain/entities/paginated_comments.dart';
import 'package:mongle_flutter/features/community/domain/repositories/comment_repository.dart';

class CommentRepositoryImpl implements CommentRepository {
  final Dio _dio;
  final TokenStorageService _tokenStorage;

  CommentRepositoryImpl(this._dio, this._tokenStorage);

  // JWT 토큰에서 memberId(sub)를 추출하는 임시 비공개 함수
  Future<String> _getRequiredMemberId() async {
    final token = await _tokenStorage.getAccessToken();
    if (token == null) {
      throw ApiException('사용자 인증 정보를 찾을 수 없습니다. 다시 로그인해주세요.');
    }
    try {
      final parts = token.split('.');
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded) as Map<String, dynamic>;
      final memberId = payloadMap['sub'] as String?;
      if (memberId == null) {
        throw ApiException('토큰에서 사용자 정보를 찾을 수 없습니다.');
      }
      return memberId;
    } catch (e) {
      throw ApiException('토큰 해석 중 오류가 발생했습니다.');
    }
  }

  @override
  Future<PaginatedComments> getComments({
    required String postId,
    String? cursor,
  }) async {
    try {
      final memberId = await _getRequiredMemberId(); // 차단 목록 조회를 위해 memberId 필요
      final response = await _dio.get(
        ApiConstants.getComments(postId),
        queryParameters: {
          'cursor': cursor,
          'size': 15, // 페이지 크기는 여기서 고정하거나 파라미터로 받을 수 있음
          'memberId': memberId,
        },
      );
      // ApiInterceptor가 data 필드를 추출해주므로 바로 fromJson 호출
      return PaginatedComments.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addComment({
    required String postId,
    required String content,
  }) async {
    try {
      final memberId = await _getRequiredMemberId();
      await _dio.post(
        ApiConstants.addComment(postId),
        queryParameters: {'memberId': memberId},
        data: {'content': content},
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addReply({
    required String parentCommentId,
    required String content,
  }) async {
    try {
      final memberId = await _getRequiredMemberId();
      await _dio.post(
        ApiConstants.addReply(parentCommentId),
        queryParameters: {'memberId': memberId},
        data: {'content': content},
      );
    } catch (e) {
      rethrow;
    }
  }
}

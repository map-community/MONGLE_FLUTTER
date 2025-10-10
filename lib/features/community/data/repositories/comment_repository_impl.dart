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

  @override
  Future<PaginatedComments> getComments({
    required String postId,
    String? cursor,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.getComments(postId),
        queryParameters: {
          'cursor': cursor,
          'size': 15, // 페이지 크기는 여기서 고정하거나 파라미터로 받을 수 있음
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
      await _dio.post(
        ApiConstants.addComment(postId),
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
      await _dio.post(
        ApiConstants.addReply(parentCommentId),
        data: {'content': content},
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PaginatedComments> getReplies({
    required String parentCommentId,
    int size = 15, // 기본값 설정
    String? cursor,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.getReplies(parentCommentId),
        queryParameters: {'cursor': cursor, 'size': size},
      );
      // ApiInterceptor가 data 필드를 추출해주므로 바로 fromJson 호출
      return PaginatedComments.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteComment({required String commentId}) async {
    try {
      await _dio.delete(ApiConstants.deleteComment(commentId));
    } catch (e) {
      rethrow;
    }
  }
}

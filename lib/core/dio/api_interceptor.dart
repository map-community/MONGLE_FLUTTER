import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/core/dio/dio_provider.dart';
import 'package:mongle_flutter/core/errors/exceptions.dart';
import 'package:mongle_flutter/features/auth/data/data_sources/token_storage_service.dart';
import 'package:mongle_flutter/features/auth/data/repositories/auth_repository_impl.dart';

class ApiInterceptor extends Interceptor {
  final Ref ref;
  ApiInterceptor(this.ref);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 1. 저장된 액세스 토큰을 가져옵니다.
    final token = await ref.read(tokenStorageServiceProvider).getAccessToken();

    // 2. 토큰이 있다면, 요청 헤더에 'Authorization'을 추가합니다.
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // 3. 수정된 옵션으로 요청을 계속 진행합니다.
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data is Map<String, dynamic> &&
        response.data.containsKey('code') &&
        response.data.containsKey('data')) {
      if (response.data['code'] == 'SUCCESS') {
        response.data = response.data['data'];
        return handler.next(response);
      } else {
        final errorMessage =
            response.data['message'] ?? 'Unknown success-error';
        final exception = ApiException(errorMessage);

        return handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            error: exception,
            response: response,
          ),
        );
      }
    }
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final responseData = err.response?.data;

    // 1. 401 에러인지 먼저 확인
    if (err.response?.statusCode == 401) {
      // 2. 응답 본문이 있고, 우리가 정의한 에러 형식인지 확인
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('code')) {
        final errorCode = responseData['code'];

        // 3. 오직 '만료된 토큰(AUTH-011)' 에러일 때만 재발급을 시도합니다.
        if (errorCode == 'AUTH-011' &&
            err.requestOptions.path != '/auth/reissue') {
          try {
            final newTokens = await ref
                .read(authRepositoryProvider)
                .reissueToken();
            final originalRequest = err.requestOptions;
            originalRequest.headers['Authorization'] =
                'Bearer ${newTokens.accessToken}';
            final response = await ref.read(dioProvider).fetch(originalRequest);
            return handler.resolve(response);
          } on DioException catch (reissueErr) {
            // 리프레시 토큰마저 만료되어 재발급에 실패한 경우
            final finalException = ApiException("세션이 만료되었습니다. 다시 로그인해주세요.");
            return handler.reject(
              DioException(
                requestOptions: reissueErr.requestOptions,
                error: finalException,
                response: reissueErr.response,
              ),
            );
          }
        }
      }
    }

    // 401 에러가 아닌 다른 모든 에러 처리 로직 (수정 없음)
    String errorMessage = '알 수 없는 오류가 발생했습니다.';

    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('message')) {
        errorMessage = responseData['message'];
      } else if (responseData.containsKey('error')) {
        final status = responseData['status'] ?? '';
        final error = responseData['error'] ?? '';
        errorMessage = '서버 요청 실패 ($status $error)';
      }
    } else {
      switch (err.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          errorMessage = '네트워크 연결 시간을 초과했습니다.';
          break;
        case DioExceptionType.cancel:
          errorMessage = '요청이 취소되었습니다.';
          break;
        default:
          errorMessage = '서버가 응답하지 않습니다.';
          break;
      }
    }

    final apiException = ApiException(errorMessage);

    final newDioException = DioException(
      requestOptions: err.requestOptions,
      error: apiException,
      response: err.response,
      type: err.type,
      message: err.message,
    );

    return handler.reject(newDioException);
  }
}

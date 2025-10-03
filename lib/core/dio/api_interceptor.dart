// lib/core/dio/api_interceptor.dart

import 'package:dio/dio.dart';
import 'package:mongle_flutter/core/errors/exceptions.dart';

class ApiInterceptor extends Interceptor {
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
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage = '알 수 없는 오류가 발생했습니다.';
    final responseData = err.response?.data;

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
          errorMessage = '네트워크 연결을 확인해주세요.';
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

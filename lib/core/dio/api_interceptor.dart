import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/core/constants/api_constants.dart';
import 'package:mongle_flutter/core/dio/dio_provider.dart';
import 'package:mongle_flutter/core/errors/exceptions.dart';
import 'package:mongle_flutter/features/auth/data/data_sources/token_storage_service.dart';
import 'package:mongle_flutter/features/auth/domain/entities/token_info.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiInterceptor extends Interceptor {
  final Ref ref;
  final Dio dio;

  // 토큰 재발급 중복 방지를 위한 변수
  Completer<TokenInfo>? _refreshCompleter;

  ApiInterceptor(this.ref, this.dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 토큰 재발급 요청은 Authorization 헤더를 추가하지 않음
    if (options.path == ApiConstants.reissue) {
      return handler.next(options);
    }

    final token = await ref.read(tokenStorageServiceProvider).getAccessToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

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
    print("🚨 [ApiInterceptor] onError 진입! 에러 타입: ${err.type}");
    print("   - 요청 경로: ${err.requestOptions.path}");

    final responseData = err.response?.data;

    // 401 에러 및 AUTH-016 코드 확인
    if (err.response?.statusCode == 401 &&
        err.requestOptions.path != ApiConstants.reissue) {
      print("🔑 [ApiInterceptor] 401 Unauthorized 에러 감지!");
      print("   - 서버 응답 데이터: $responseData");

      if (responseData is Map<String, dynamic> &&
          responseData['code'] == 'AUTH-016') {
        print("🔄 [ApiInterceptor] 'AUTH-016' 코드 확인! 토큰 재발급을 시도합니다.");

        try {
          // 토큰 재발급 (중복 방지 로직 포함)
          final newTokenInfo = await _refreshToken();

          // 원래 요청 재시도
          final originalRequest = err.requestOptions;
          originalRequest.headers['Authorization'] =
              'Bearer ${newTokenInfo.accessToken}';

          print("🔁 [ApiInterceptor] 새로운 토큰으로 원래 요청을 재시도합니다.");

          // ⚠️ 핵심: 인터셉터를 거치지 않는 새로운 Dio 인스턴스로 재시도
          final retryDio = Dio(dio.options);
          final response = await retryDio.fetch(originalRequest);

          return handler.resolve(response);
        } catch (e) {
          print("‼️ [ApiInterceptor] 토큰 재발급 실패! 로그인 필요.");
          print("   - 실패 원인: $e");

          final finalException = ApiException("세션이 만료되었습니다. 다시 로그인해주세요.");

          // 로그아웃 처리 (선택사항)
          // ref.read(authProvider.notifier).logout();

          return handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              error: finalException,
              response: err.response,
            ),
          );
        }
      }
    }

    // 401 외 다른 에러 처리
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

    return handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: apiException,
        response: err.response,
        type: err.type,
        message: err.message,
      ),
    );
  }

  /// 토큰 재발급 (중복 요청 방지 로직 포함)
  Future<TokenInfo> _refreshToken() async {
    // 이미 재발급 진행 중이면 기존 Future를 반환
    if (_refreshCompleter != null) {
      print("⏳ [ApiInterceptor] 이미 토큰 재발급 진행 중... 대기합니다.");
      return _refreshCompleter!.future;
    }

    // 새로운 재발급 시작
    _refreshCompleter = Completer<TokenInfo>();

    try {
      final tokenStorage = ref.read(tokenStorageServiceProvider);
      final refreshToken = await tokenStorage.getRefreshToken();

      if (refreshToken == null) {
        throw Exception('No refresh token');
      }

      // 인터셉터가 없는 깨끗한 Dio 인스턴스 생성
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );

      print("📡 [ApiInterceptor] 토큰 재발급 API 호출 중...");

      final refreshResponse = await refreshDio.post(
        ApiConstants.reissue,
        data: {'refreshToken': refreshToken},
      );

      final newTokenInfo = TokenInfo.fromJson(refreshResponse.data['data']);

      await tokenStorage.saveTokens(newTokenInfo);

      print("✅ [ApiInterceptor] 토큰 재발급 성공!");

      // 대기 중인 모든 요청에 결과 전달
      _refreshCompleter!.complete(newTokenInfo);

      return newTokenInfo;
    } catch (e) {
      print("❌ [ApiInterceptor] 토큰 재발급 실패: $e");
      _refreshCompleter!.completeError(e);
      rethrow;
    } finally {
      _refreshCompleter = null;
    }
  }
}

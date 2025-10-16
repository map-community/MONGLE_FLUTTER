import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/core/constants/api_constants.dart';
import 'package:mongle_flutter/core/dio/dio_provider.dart';
import 'package:mongle_flutter/core/errors/exceptions.dart';
import 'package:mongle_flutter/features/auth/data/data_sources/token_storage_service.dart';
import 'package:mongle_flutter/features/auth/domain/entities/token_info.dart';
import 'package:mongle_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:synchronized/synchronized.dart';

class ApiInterceptor extends Interceptor {
  final Ref ref;

  // 토큰 재발급 중복 방지를 위한 변수
  static Completer<TokenInfo>? _refreshCompleter;
  static final _lock = Lock(); // Object() 대신 Lock() 사용

  ApiInterceptor(this.ref);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 토큰 재발급 요청은 Authorization 헤더를 추가하지 않음
    if (options.path.contains(ApiConstants.reissue)) {
      return handler.next(options);
    }

    try {
      final token = await ref
          .read(tokenStorageServiceProvider)
          .getAccessToken();

      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      print("❌ [ApiInterceptor] 토큰 읽기 실패: $e");
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 토큰 재발급 응답은 그대로 통과
    if (response.requestOptions.path.contains(ApiConstants.reissue)) {
      return handler.next(response);
    }

    // 일반 응답 처리
    if (response.data is Map<String, dynamic> &&
        response.data.containsKey('code') &&
        response.data.containsKey('data')) {
      if (response.data['code'] == 'SUCCESS') {
        response.data = response.data['data'];
        return handler.next(response);
      } else {
        final errorMessage = response.data['message'] ?? 'Unknown error';
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
    print("🚨 [ApiInterceptor] Error: ${err.response?.statusCode}");
    print("   - Path: ${err.requestOptions.path}");
    print("   - Response: ${err.response?.data}");

    // 토큰 재발급 요청 자체가 실패한 경우
    if (err.requestOptions.path.contains(ApiConstants.reissue)) {
      print("❌ [ApiInterceptor] 토큰 재발급 자체가 실패!");
      await _handleLogout();
      return handler.reject(err);
    }

    // 401 에러 처리
    if (err.response?.statusCode == 401) {
      final responseData = err.response?.data;

      if (responseData is Map<String, dynamic>) {
        final errorCode = responseData['code'];

        // ✅ AUTH-015: 유효하지 않은 토큰 → 즉시 로그아웃
        if (errorCode == 'AUTH-015') {
          print("❌ [ApiInterceptor] 유효하지 않은 토큰 감지! 로그아웃 처리...");
          await _handleLogout();

          return handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              error: ApiException("세션이 만료되었습니다. 다시 로그인해주세요."),
              response: err.response,
            ),
          );
        }

        // ✅ AUTH-016: 만료된 토큰 → 재발급 시도
        if (errorCode == 'AUTH-016') {
          print("🔄 [ApiInterceptor] 액세스 토큰 만료 감지! 재발급 시도...");

          try {
            final newTokenInfo = await _refreshTokenWithLock();

            if (newTokenInfo != null) {
              final originalRequest = err.requestOptions;
              originalRequest.headers['Authorization'] =
                  'Bearer ${newTokenInfo.accessToken}';

              print("🔁 [ApiInterceptor] 새 토큰으로 재시도...");

              // refreshDioProvider 사용 (무한루프 방지)
              final retryDio = ref.read(refreshDioProvider);

              final response = await retryDio.request(
                originalRequest.path,
                data: originalRequest.data,
                queryParameters: originalRequest.queryParameters,
                options: Options(
                  method: originalRequest.method,
                  headers: originalRequest.headers,
                ),
              );

              // ✅ 추가: SUCCESS 체크 및 data 추출
              if (response.data is Map<String, dynamic> &&
                  response.data['code'] == 'SUCCESS') {
                response.data = response.data['data'];
              }

              return handler.resolve(response);
            }
          } catch (e) {
            print("❌ [ApiInterceptor] 토큰 재발급 또는 재시도 실패: $e");
            await _handleLogout();

            return handler.reject(
              DioException(
                requestOptions: err.requestOptions,
                error: ApiException("세션이 만료되었습니다. 다시 로그인해주세요."),
                response: err.response,
              ),
            );
          }
        }
      }
    }

    // 기타 에러 처리
    String errorMessage = _extractErrorMessage(err);

    return handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: ApiException(errorMessage),
        response: err.response,
        type: err.type,
      ),
    );
  }

  /// 동기화된 토큰 재발급
  Future<TokenInfo?> _refreshTokenWithLock() async {
    // [수정] synchronized 블록 안으로 completer를 옮기지 않고,
    // lock의 핵심 기능에만 집중합니다.
    if (_refreshCompleter != null) {
      print("⏳ [ApiInterceptor] 이미 토큰 재발급 중... 대기");
      return _refreshCompleter!.future;
    }

    // 새로운 재발급 시작
    _refreshCompleter = Completer<TokenInfo>();

    try {
      final tokenInfo = await _refreshToken();
      // 성공 시 결과를 모든 대기자에게 전달
      _refreshCompleter!.complete(tokenInfo);
      return tokenInfo;
    } catch (e) {
      // 실패 시 에러를 모든 대기자에게 전달
      _refreshCompleter!.completeError(e);
      rethrow; // 현재 요청에 대한 에러는 다시 던져서 처리
    } finally {
      // [수정] 작업이 끝나면 즉시 completer를 null로 만들어 다음 요청이 새 작업을 시작할 수 있도록 합니다.
      // delayed를 사용하면 그 사이에 다른 요청이 들어와 문제를 일으킬 수 있습니다.
      _refreshCompleter = null;
    }
  }

  /// 실제 토큰 재발급 로직
  Future<TokenInfo> _refreshToken() async {
    final tokenStorage = ref.read(tokenStorageServiceProvider);
    final refreshToken = await tokenStorage.getRefreshToken();

    if (refreshToken == null) {
      throw Exception('리프레시 토큰이 없습니다');
    }

    print("📡 [ApiInterceptor] 토큰 재발급 API 호출...");

    // refreshDioProvider 사용
    final refreshDio = ref.read(refreshDioProvider);

    final response = await refreshDio.post(
      ApiConstants.reissue,
      data: {'refreshToken': refreshToken},
    );

    // 응답 데이터 파싱
    Map<String, dynamic> responseData = response.data;

    if (responseData['code'] == 'SUCCESS') {
      final newTokenInfo = TokenInfo.fromJson(responseData['data']);

      // 토큰 저장
      await tokenStorage.saveTokens(newTokenInfo);

      print("✅ [ApiInterceptor] 토큰 재발급 성공!");

      return newTokenInfo;
    } else {
      throw ApiException(responseData['message'] ?? '토큰 재발급 실패');
    }
  }

  /// 로그아웃 처리
  Future<void> _handleLogout() async {
    try {
      // 토큰 삭제
      await ref.read(tokenStorageServiceProvider).clearTokens();

      // 인증 상태 업데이트
      ref.read(authProvider.notifier).forceLogout();
    } catch (e) {
      print("❌ [ApiInterceptor] 로그아웃 처리 중 오류: $e");
    }
  }

  String _extractErrorMessage(DioException err) {
    final responseData = err.response?.data;

    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('message')) {
        return responseData['message'];
      }
    }

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return '네트워크 연결 시간을 초과했습니다.';
      case DioExceptionType.connectionError:
        return '네트워크 연결에 실패했습니다.';
      default:
        return '서버가 응답하지 않습니다.';
    }
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/core/constants/api_constants.dart';
import 'package:mongle_flutter/core/dio/dio_provider.dart';
import 'package:mongle_flutter/core/errors/exceptions.dart';
import 'package:mongle_flutter/features/auth/data/data_sources/token_storage_service.dart';
import 'package:mongle_flutter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mongle_flutter/features/auth/domain/entities/token_info.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    print("🚨 [ApiInterceptor] onError 진입! 에러 타입: ${err.type}");
    print("   - 요청 경로: ${err.requestOptions.path}");

    final responseData = err.response?.data;
    if (err.response?.statusCode == 401) {
      print("🔑 [ApiInterceptor] 401 Unauthorized 에러 감지!");
      print("   - 서버 응답 데이터: $responseData");

      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('code')) {
        final errorCode = responseData['code'];
        if (errorCode == 'AUTH-016' &&
            err.requestOptions.path != ApiConstants.reissue) {
          print("🔄 [ApiInterceptor] 'AUTH-016' 코드 확인! 토큰 재발급을 시도합니다.");

          // '/auth/reissue' 대신 상수 사용
          try {
            // 👇 [핵심 수정] authRepository를 호출하는 대신, 재발급 로직을 인터셉터 내에서 직접 수행
            final tokenStorage = ref.read(tokenStorageServiceProvider);
            final refreshToken = await tokenStorage.getRefreshToken();
            if (refreshToken == null) {
              print("❌ [ApiInterceptor] 저장된 리프레시 토큰이 없습니다. 재발급 불가.");
              throw Exception('No refresh token');
            }

            // 1. 토큰 재발급 전용으로 사용할 새로운 '깨끗한' Dio 인스턴스를 생성
            final refreshDio = Dio(
              // .env 파일에서 직접 baseUrl을 읽어옵니다.
              BaseOptions(
                baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080',
              ),
            );

            print("✅ [ApiInterceptor] 새로운 액세스 토큰 발급 성공!");

            // 2. 새로 생성한 dio 인스턴스로 API 호출 (이 요청은 인터셉터를 타지 않음)
            final refreshResponse = await refreshDio.post(
              ApiConstants.reissue,
              data: {'refreshToken': refreshToken},
            );

            // 3. 새로운 토큰 정보 저장
            final newTokenInfo = TokenInfo.fromJson(
              refreshResponse.data['data'],
            );
            await tokenStorage.saveTokens(newTokenInfo);

            // 4. 원래의 요청에 새로운 액세스 토큰을 담아 재시도
            final originalRequest = err.requestOptions;
            originalRequest.headers['Authorization'] =
                'Bearer ${newTokenInfo.accessToken}';

            print("🔁 [ApiInterceptor] 새로운 토큰으로 원래 요청을 재시도합니다.");

            // 5. 원래의 dioProvider를 사용하여 원래 요청을 재시도
            final response = await ref.read(dioProvider).fetch(originalRequest);
            return handler.resolve(response);
          } on DioException catch (reissueErr) {
            print("‼️ [ApiInterceptor] 리프레시 토큰으로 재발급 실패! 로그인 화면으로 보내야 합니다.");
            print("   - 재발급 실패 원인: ${reissueErr.response?.data}");

            // 리프레시 토큰마저 만료되어 재발급에 실패한 경우
            final finalException = ApiException("세션이 만료되었습니다. 다시 로그인해주세요.");
            // 여기서 로그아웃 처리 로직을 호출할 수도 있습니다.
            // ref.read(authProvider.notifier).logout();
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

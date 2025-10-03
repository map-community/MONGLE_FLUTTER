import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/core/constants/api_constants.dart';
import 'package:mongle_flutter/core/dio/dio_provider.dart';
import 'package:mongle_flutter/core/errors/exceptions.dart';
import 'package:mongle_flutter/features/auth/data/data_sources/token_storage_service.dart';
import 'package:mongle_flutter/features/auth/domain/entities/login_request.dart';
import 'package:mongle_flutter/features/auth/domain/entities/sign_up_request.dart';
import 'package:mongle_flutter/features/auth/domain/entities/token_info.dart';
import 'package:mongle_flutter/features/auth/domain/repositories/auth_repository.dart';

// 이 구현체를 앱 전역에서 사용할 수 있도록 Provider로 만듭니다.
// UI나 다른 로직에서는 이 Provider를 통해 AuthRepository의 기능에 접근합니다.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // ref.watch를 통해 필요한 다른 Provider(dio, tokenStorage)를 주입받습니다. (의존성 주입)
  final dio = ref.watch(dioProvider);
  final tokenStorage = ref.watch(tokenStorageServiceProvider);
  return AuthRepositoryImpl(dio, tokenStorage);
});

// '계약서'인 AuthRepository를 실제로 '구현'하는 클래스
class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final TokenStorageService _tokenStorage;

  AuthRepositoryImpl(this._dio, this._tokenStorage);

  @override
  Future<TokenInfo> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: request.toJson(),
      );

      // ApiInterceptor 덕분에, 우리는 ApiResponse 껍데기를 신경 쓸 필요 없이
      // response.data가 바로 data 필드의 내용(TokenInfo의 JSON)임을 확신할 수 있습니다.
      final tokenInfo = TokenInfo.fromJson(response.data);

      // 받은 토큰을 안전한 금고에 저장합니다.
      await _tokenStorage.saveTokens(tokenInfo);

      return tokenInfo;
    } on DioException catch (e) {
      // 👇 [핵심 수정] DioException 발생 시 서버가 보낸 에러 메시지를 추출합니다.
      final responseData = e.response?.data;
      String errorMessage = '알 수 없는 오류가 발생했습니다.';

      // 서버가 JSON 형태의 에러 응답을 보냈는지 확인
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('message')) {
        errorMessage = responseData['message'];
      }

      // 추출한 메시지를 ApiException에 담아서 던집니다.
      throw ApiException(errorMessage);
    } catch (e) {
      // DioException이 아닌 다른 종류의 에러 처리
      throw ApiException('로그인 중 오류가 발생했습니다.');
    }
  }

  @override
  Future<void> signUp(SignUpRequest request) async {
    try {
      // 회원가입 API는 성공 시 특별한 데이터를 반환하지 않으므로, 호출만 수행합니다.
      await _dio.post(ApiConstants.signUp, data: request.toJson());
    } on DioException catch (e) {
      // 👇 [핵심 수정] 회원가입 실패 시에도 동일하게 서버 메시지를 추출합니다.
      final responseData = e.response?.data;
      String errorMessage = '알 수 없는 오류가 발생했습니다.';

      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('message')) {
        errorMessage = responseData['message'];
      }

      throw ApiException(errorMessage);
    } catch (e) {
      throw ApiException('회원가입 중 오류가 발생했습니다.');
    }
  }

  @override
  Future<void> logout() async {
    // 서버에 로그아웃 요청을 보낼 수도 있고 (선택사항),
    // 우선 클라이언트의 토큰만 삭제하여 로그아웃 상태로 만듭니다.
    await _tokenStorage.clearTokens();
  }
}

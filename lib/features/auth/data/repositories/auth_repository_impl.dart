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
  }

  @override
  Future<void> signUp(SignUpRequest request) async {
    // 회원가입 API는 성공 시 특별한 데이터를 반환하지 않으므로, 호출만 수행합니다.
    await _dio.post(ApiConstants.signUp, data: request.toJson());
  }

  @override
  Future<void> logout() async {
    // 서버에 로그아웃 요청을 보낼 수도 있고 (선택사항),
    // 우선 클라이언트의 토큰만 삭제하여 로그아웃 상태로 만듭니다.
    await _tokenStorage.clearTokens();
  }

  @override
  Future<TokenInfo> reissueToken() async {
    // 1. 저장소에서 리프레시 토큰을 가져옵니다.
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) {
      throw Exception('No refresh token available.'); // 리프레시 토큰이 없으면 에러 발생
    }

    // 2. 재발급 API 호출 시에는 인터셉터를 타지 않는 별도의 Dio 인스턴스를 사용할 수 있습니다.
    //    (무한 루프 방지를 위해) 여기서는 간단하게 기존 dio를 사용합니다.
    final response = await _dio.post(
      ApiConstants.reissue,
      data: {'refreshToken': refreshToken},
    );

    // 3. 서버로부터 새로운 토큰 정보를 받아옵니다.
    final newTokenInfo = TokenInfo.fromJson(response.data);

    // 4. 새로 받은 토큰들을 다시 안전하게 저장합니다.
    await _tokenStorage.saveTokens(newTokenInfo);

    // 5. 새로운 토큰 정보를 반환합니다.
    return newTokenInfo;
  }
}

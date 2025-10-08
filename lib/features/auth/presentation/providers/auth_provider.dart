import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/core/errors/exceptions.dart';
import 'package:mongle_flutter/features/auth/data/data_sources/token_storage_service.dart';
import 'package:mongle_flutter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mongle_flutter/features/auth/domain/entities/login_request.dart';
import 'package:mongle_flutter/features/auth/domain/entities/sign_up_request.dart';
import 'package:mongle_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:mongle_flutter/features/auth/presentation/providers/auth_state.dart';
import 'package:mongle_flutter/features/community/providers/issue_grain_providers.dart';
import 'package:mongle_flutter/features/map/presentation/viewmodels/map_viewmodel.dart';
import 'package:flutter/services.dart';

/// StateNotifierProvider를 생성하여 앱 전역에 AuthNotifier 인스턴스를 제공합니다.
/// UI는 이 Provider를 통해 인증 상태를 구독하고, Notifier의 메서드를 호출하여 상태를 변경합니다.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  // `ref.watch`를 사용하여 필요한 다른 Provider(Repository, TokenStorage)를 주입받습니다.
  final authRepository = ref.watch(authRepositoryProvider);
  final tokenStorage = ref.watch(tokenStorageServiceProvider);

  // AuthNotifier를 생성할 때 의존성을 전달해줍니다.
  return AuthNotifier(ref, authRepository, tokenStorage);
});

/// '상태'인 AuthState를 관리하는 '관리자(Notifier)' 클래스입니다.
/// 앱의 모든 인증 관련 비즈니스 로직(로그인, 로그아웃 등)을 담당합니다.
class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  final AuthRepository _authRepository;
  final TokenStorageService _tokenStorage;

  /// 생성자에서 Repository와 TokenStorage를 받고, 초기 상태를 .initial()로 설정합니다.
  AuthNotifier(this._ref, this._authRepository, this._tokenStorage)
    : super(const AuthState.initial()) {
    // Notifier가 처음 생성될 때, 기기에 저장된 토큰이 있는지 확인하여 자동 로그인을 시도합니다.
    _checkToken();
  }

  /// 앱 시작 시 토큰 확인 및 자동 로그인 로직
  Future<void> _checkToken() async {
    // 안전한 저장소에서 AccessToken을 읽어옵니다.
    final accessToken = await _tokenStorage.getAccessToken();

    // 토큰이 존재하면 '인증된' 상태로, 없으면 '비인증' 상태로 설정합니다.
    // (더 정교하게는 토큰 유효성 검사 API를 호출할 수도 있습니다.)
    if (accessToken != null) {
      state = const AuthState.authenticated();
    } else {
      state = const AuthState.unauthenticated();
    }
  }

  /// 로그인 메서드
  Future<void> login(String email, String password) async {
    state = const AuthState.loading(); // 상태를 '로딩 중'으로 변경
    try {
      final loginRequest = LoginRequest(email: email, password: password);
      await _authRepository.login(loginRequest); // Repository를 통해 로그인 시도
      state = const AuthState.authenticated(); // 성공 시 '인증됨' 상태로 변경
    } on DioException catch (e) {
      // ApiInterceptor가 가공해준 에러 메시지를 상태에 담습니다.
      state = AuthState.unauthenticated(message: e.error.toString());
    } catch (e) {
      // DioException 외의 예외 상황을 위한 최종 안전망
      state = AuthState.unauthenticated(message: '로그인 중 예상치 못한 오류가 발생했습니다.');
    }
  }

  /// 회원가입 메서드
  Future<bool> signUp(String email, String password, String nickname) async {
    state = const AuthState.loading();
    try {
      final signUpRequest = SignUpRequest(
        email: email,
        password: password,
        nickname: nickname,
      );
      await _authRepository.signUp(signUpRequest);

      // 회원가입 성공 후, 동일한 정보로 바로 로그인을 시도합니다.
      await login(email, password);
      return true;
    } on DioException catch (e) {
      state = AuthState.unauthenticated(message: e.error.toString());
      return false;
    } catch (e) {
      state = AuthState.unauthenticated(message: '회원가입 중 예상치 못한 오류가 발생했습니다.');
      return false;
    }
  }

  /// 로그아웃 - 전체 앱 재시작 트리거
  Future<void> logout() async {
    try {
      await _authRepository.logout();
    } catch (e) {
      print("로그아웃 중 오류 발생: $e");
    } finally {
      state = const AuthState.unauthenticated();

      // 앱 전체 재시작 신호 (UniqueKey 생성으로 위젯 트리 재생성)
      _ref.read(appRestartTriggerProvider.notifier).triggerRestart();
    }
  }
}

/// 앱 전체 재시작을 위한 Provider
/// UniqueKey를 사용하여 매번 새로운 key를 생성
final appRestartTriggerProvider = StateProvider<Object>((ref) {
  return Object(); // 초기값
});

extension AppRestartExtension on StateController<Object> {
  void triggerRestart() {
    state = Object(); // 새로운 Object 인스턴스 = 새로운 identity
  }
}

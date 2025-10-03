import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/auth/domain/entities/login_request.dart';
import 'package:mongle_flutter/features/auth/domain/entities/sign_up_request.dart';
import 'package:mongle_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:mongle_flutter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mongle_flutter/features/auth/presentation/providers/auth_state.dart';

// 1. StateNotifierProvider를 생성하여 앱 전역에 AuthNotifier 인스턴스를 제공합니다.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  // 2. AuthRepository의 구현체를 주입받습니다.
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});

// 3. '상태'인 AuthState를 관리하는 '관리자' 클래스
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  // 4. 생성자에서 AuthRepository를 받고, 초기 상태를 .initial()로 설정합니다.
  AuthNotifier(this._authRepository) : super(const AuthState.initial()) {
    // 5. Notifier가 생성되자마자, 기기에 저장된 토큰이 있는지 확인하여 자동 로그인을 시도합니다.
    _checkToken();
  }

  // 앱 시작 시 토큰 확인 및 자동 로그인
  Future<void> _checkToken() async {
    // TODO: TokenStorageService에서 토큰을 읽어와 유효성을 검사하는 로직 추가
    // 지금은 임시로 비인증 상태로 설정합니다.
    state = const AuthState.unauthenticated();
  }

  // 로그인 메서드
  Future<void> login(String email, String password) async {
    state = const AuthState.loading(); // 6. 상태를 '로딩 중'으로 변경
    try {
      final loginRequest = LoginRequest(email: email, password: password);
      await _authRepository.login(loginRequest); // 7. Repository를 통해 로그인 시도
      state = const AuthState.authenticated(); // 8. 성공 시 '인증됨' 상태로 변경
    } catch (e) {
      // 9. 실패 시 '비인증' 상태로 변경하고 에러 메시지를 전달
      state = AuthState.unauthenticated(message: e.toString());
    }
  }

  // 회원가입 메서드
  Future<bool> signUp(String email, String password, String nickname) async {
    state = const AuthState.loading();
    try {
      final signUpRequest = SignUpRequest(
        email: email,
        password: password,
        nickname: nickname,
      );
      await _authRepository.signUp(signUpRequest);
      // 회원가입 성공 후 바로 로그인 시도
      await login(email, password);
      return true;
    } catch (e) {
      state = AuthState.unauthenticated(message: e.toString());
      return false;
    }
  }

  // 로그아웃 메서드
  Future<void> logout() async {
    await _authRepository.logout();
    state = const AuthState.unauthenticated();
  }
}

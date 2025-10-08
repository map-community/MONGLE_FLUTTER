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

  // 이메일 인증 코드를 요청하는 메서드
  /// 성공 시 null을, 실패 시 에러 메시지를 String으로 반환합니다.
  Future<String?> requestVerificationCode(String email) async {
    try {
      await _authRepository.requestVerificationCode(email);
      return null; // 성공적으로 요청이 완료되면 null을 반환합니다.
    } on DioException catch (e) {
      // Dio를 통해 발생한 예외 (네트워크, 서버 4xx/5xx 에러 등)
      // ApiInterceptor가 가공해준 깔끔한 에러 메시지를 반환합니다.
      return e.error.toString();
    } catch (e) {
      // DioException 외에 예상치 못한 다른 종류의 에러가 발생한 경우
      return '알 수 없는 오류가 발생했습니다.';
    }
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
      // ✅ 개선: ApiInterceptor가 처리한 메시지 사용
      final errorMessage = _extractErrorMessage(e);
      state = AuthState.unauthenticated(message: errorMessage);
    } catch (e) {
      // DioException 외의 예외 상황을 위한 최종 안전망
      state = AuthState.unauthenticated(message: '로그인 중 예상치 못한 오류가 발생했습니다.');
    }
  }

  /// 로그아웃 - 전체 앱 재시작 트리거
  /// 로그아웃 메서드
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

  // 회원 탈퇴 메서드
  Future<String?> withdraw() async {
    state = const AuthState.loading();
    try {
      await _authRepository.withdraw();
      // 탈퇴 성공 후, 로그아웃 처리를 통해 상태를 정리합니다.
      await logout();
      return null; // 성공 시 null 반환
    } on DioException catch (e) {
      print("회원 탈퇴 중 오류 발생: $e");
      final errorMessage = _extractErrorMessage(e);
      if (mounted) {
        // 실패 시 다시 'authenticated' 상태로 복원
        state = const AuthState.authenticated();
      }
      return errorMessage; // 실패 시 에러 메시지 반환
    } catch (e) {
      print("회원 탈퇴 중 예상치 못한 오류 발생: $e");
      if (mounted) {
        state = const AuthState.authenticated();
      }
      return '알 수 없는 오류로 탈퇴에 실패했습니다.';
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

/// ✅ 개선: ApiInterceptor가 처리한 에러 메시지를 추출
/// DioException.error에 ApiException이 담겨 있으므로 이를 활용
String _extractErrorMessage(DioException e) {
  // 1. ApiInterceptor가 담아준 ApiException 메시지 확인
  if (e.error is ApiException) {
    return (e.error as ApiException).message;
  }

  // 2. error 필드가 String인 경우
  if (e.error is String) {
    return e.error as String;
  }

  // 3. 그 외의 경우 (네트워크 오류 등)
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return '네트워크 연결 시간을 초과했습니다.';
    case DioExceptionType.connectionError:
      return '네트워크 연결에 실패했습니다.';
    case DioExceptionType.cancel:
      return '요청이 취소되었습니다.';
    default:
      return '알 수 없는 오류가 발생했습니다.';
  }
}

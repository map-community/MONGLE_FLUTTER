// lib/features/auth/presentation/providers/sign_up_notifier.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/core/errors/exceptions.dart';
import 'package:mongle_flutter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mongle_flutter/features/auth/domain/entities/sign_up_request.dart';
import 'package:mongle_flutter/features/auth/domain/entities/verify_code_request.dart';
import 'package:mongle_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:mongle_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:mongle_flutter/features/auth/presentation/providers/sign_up_state.dart';

final signUpProvider = StateNotifierProvider<SignUpNotifier, SignUpState>((
  ref,
) {
  final authRepository = ref.watch(authRepositoryProvider);
  return SignUpNotifier(ref, authRepository);
});

class SignUpNotifier extends StateNotifier<SignUpState> {
  final Ref _ref;
  final AuthRepository _authRepository;

  SignUpNotifier(this._ref, this._authRepository) : super(const SignUpState());

  /// 🔹 1단계: 이메일 인증 코드 발송
  Future<String?> requestVerificationCode(String email) async {
    // Rate Limiting 체크 (30초 이내 재발송 방지)
    if (state.lastCodeSentAt != null) {
      final difference = DateTime.now().difference(state.lastCodeSentAt!);
      if (difference.inSeconds < 30) {
        return '${30 - difference.inSeconds}초 후에 다시 시도해주세요.';
      }
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _authRepository.requestVerificationCode(email);

      state = state.copyWith(
        step: SignUpStep.verificationSent,
        email: email,
        lastCodeSentAt: DateTime.now(),
        codeSendCount: state.codeSendCount + 1,
        isLoading: false,
      );

      return null;
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      state = state.copyWith(errorMessage: errorMessage, isLoading: false);
      return errorMessage;
    } catch (e) {
      const errorMessage = '인증 코드 발송 중 오류가 발생했습니다.';
      state = state.copyWith(errorMessage: errorMessage, isLoading: false);
      return errorMessage;
    }
  }

  /// 🔹 2단계: 인증 코드 확인 및 verificationToken 발급
  Future<String?> verifyCode(String verificationCode) async {
    if (state.email == null) {
      return '이메일 정보가 없습니다. 처음부터 다시 시도해주세요.';
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final request = VerifyCodeRequest(
        email: state.email!,
        verificationCode: verificationCode,
      );

      final response = await _authRepository.verifyCode(request);

      // verificationToken 만료 시간 설정 (10분)
      final expiryTime = DateTime.now().add(const Duration(minutes: 10));

      state = state.copyWith(
        step: SignUpStep.passwordInput, // 바로 비밀번호 입력 단계로
        verificationToken: response.verificationToken,
        tokenExpiryTime: expiryTime,
        isLoading: false,
      );

      return null;
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      state = state.copyWith(errorMessage: errorMessage, isLoading: false);
      return errorMessage;
    } catch (e) {
      const errorMessage = '인증 코드 확인 중 오류가 발생했습니다.';
      state = state.copyWith(errorMessage: errorMessage, isLoading: false);
      return errorMessage;
    }
  }

  /// 🆕 3단계: 비밀번호 저장 및 다음 단계로 이동
  void savePassword(String password) {
    state = state.copyWith(password: password, step: SignUpStep.nicknameInput);
  }

  /// 🆕 4단계: 닉네임 저장 및 다음 단계로 이동
  void saveNickname(String nickname) {
    state = state.copyWith(
      nickname: nickname,
      step: SignUpStep.termsAgreement, // 약관 동의 화면으로
    );
  }

  /// 🆕 서비스 이용약관 동의 토글
  void toggleTermsAgreement(bool value) {
    state = state.copyWith(termsAgreed: value);
  }

  /// 🆕 개인정보 처리방침 동의 토글
  void togglePrivacyAgreement(bool value) {
    state = state.copyWith(privacyAgreed: value);
  }

  /// 🆕 전체 동의
  void toggleAllAgreements(bool value) {
    state = state.copyWith(termsAgreed: value, privacyAgreed: value);
  }

  /// 🆕 5단계: 최종 회원가입 (약관 동의 완료 후)
  Future<bool> signUp() async {
    // 🔹 파라미터 없음!
    if (state.email == null ||
        state.verificationToken == null ||
        state.password == null ||
        state.nickname == null) {
      // 🆕 닉네임 체크 추가
      state = state.copyWith(errorMessage: '필수 정보가 누락되었습니다. 처음부터 다시 시도해주세요.');
      return false;
    }

    // 🆕 약관 동의 체크
    if (!state.termsAgreed || !state.privacyAgreed) {
      state = state.copyWith(errorMessage: '모든 약관에 동의해주세요.');
      return false;
    }

    // verificationToken 만료 체크
    if (state.tokenExpiryTime != null &&
        DateTime.now().isAfter(state.tokenExpiryTime!)) {
      state = state.copyWith(
        errorMessage: '인증 시간이 만료되었습니다. 처음부터 다시 시도해주세요.',
        step: SignUpStep.emailInput,
        verificationToken: null,
        password: null,
        nickname: null, // 🆕
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final request = SignUpRequest(
        email: state.email!,
        password: state.password!,
        nickname: state.nickname!, // 🔹 State에서 가져옴
        verificationToken: state.verificationToken!,
      );

      await _authRepository.signUp(request);

      // 회원가입 성공 후 자동 로그인
      await _ref
          .read(authProvider.notifier)
          .login(state.email!, state.password!);

      state = state.copyWith(
        step: SignUpStep.completed,
        isLoading: false,
        password: null,
        nickname: null, // 🆕
      );

      return true;
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      state = state.copyWith(errorMessage: errorMessage, isLoading: false);
      return false;
    } catch (e) {
      const errorMessage = '회원가입 중 오류가 발생했습니다.';
      state = state.copyWith(errorMessage: errorMessage, isLoading: false);
      return false;
    }
  }

  /// 처음으로 돌아가기 (리셋)
  void reset() {
    state = const SignUpState();
  }

  /// 🆕 이전 단계로 돌아가기
  void goToPreviousStep() {
    switch (state.step) {
      case SignUpStep.verificationSent:
        state = state.copyWith(step: SignUpStep.emailInput);
        break;
      case SignUpStep.passwordInput:
        state = state.copyWith(step: SignUpStep.verificationSent);
        break;
      case SignUpStep.nicknameInput:
        state = state.copyWith(step: SignUpStep.passwordInput, password: null);
        break;
      case SignUpStep.termsAgreement: // 🆕
        state = state.copyWith(step: SignUpStep.nicknameInput, nickname: null);
        break;
      default:
        break;
    }
  }

  /// ApiInterceptor가 처리한 에러 메시지를 추출
  String _extractErrorMessage(DioException e) {
    if (e.error is ApiException) {
      return (e.error as ApiException).message;
    }

    if (e.error is String) {
      return e.error as String;
    }

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
}

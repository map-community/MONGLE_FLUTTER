import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_state.freezed.dart';

/// 회원가입 진행 단계
enum SignUpStep {
  emailInput, // 1단계: 이메일 입력
  verificationSent, // 2단계: 인증 코드 발송됨 → 코드 입력
  passwordInput, // 3단계: 비밀번호 입력 (🆕 분리!)
  nicknameInput, // 4단계: 닉네임 입력 (🆕 분리!)
  completed, // 가입 완료
}

/// 회원가입 전용 State
@freezed
abstract class SignUpState with _$SignUpState {
  const factory SignUpState({
    @Default(SignUpStep.emailInput) SignUpStep step,
    String? email,
    String? verificationToken,
    DateTime? tokenExpiryTime, // verificationToken 만료 시간 (10분)
    String? password, // 🆕 비밀번호 임시 저장
    String? errorMessage,
    @Default(false) bool isLoading,
    DateTime? lastCodeSentAt, // 마지막 인증 코드 발송 시간
    @Default(0) int codeSendCount, // 인증 코드 발송 횟수
  }) = _SignUpState;
}

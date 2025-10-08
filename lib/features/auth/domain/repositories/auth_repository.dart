// lib/features/auth/domain/repositories/auth_repository.dart

import 'package:mongle_flutter/features/auth/domain/entities/login_request.dart';
import 'package:mongle_flutter/features/auth/domain/entities/sign_up_request.dart';
import 'package:mongle_flutter/features/auth/domain/entities/token_info.dart';
import 'package:mongle_flutter/features/auth/domain/entities/verify_code_request.dart';
import 'package:mongle_flutter/features/auth/domain/entities/verify_code_response.dart';

// 인증(Authentication)과 관련된 데이터 통신 규칙을 정의하는 '계약서'
abstract class AuthRepository {
  // 이메일 인증 코드를 요청하는 기능
  Future<void> requestVerificationCode(String email);

  // 인증 코드 확인 및 verificationToken 발급
  Future<VerifyCodeResponse> verifyCode(VerifyCodeRequest request);

  // 회원가입을 요청하는 기능
  Future<void> signUp(SignUpRequest request);

  // 로그인을 요청하고 성공 시 토큰 정보를 반환하는 기능
  Future<TokenInfo> login(LoginRequest request);

  // 로그아웃을 요청하는 기능
  Future<void> logout();

  // 리프레시 토큰으로 새로운 토큰들을 발급받는 기능
  Future<TokenInfo> reissueToken();
}

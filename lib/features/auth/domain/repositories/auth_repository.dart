// lib/features/auth/domain/repositories/auth_repository.dart

import 'package:mongle_flutter/features/auth/domain/entities/login_request.dart';
import 'package:mongle_flutter/features/auth/domain/entities/sign_up_request.dart';
import 'package:mongle_flutter/features/auth/domain/entities/token_info.dart';

// 인증(Authentication)과 관련된 데이터 통신 규칙을 정의하는 '계약서'
abstract class AuthRepository {
  // 회원가입을 요청하는 기능
  Future<void> signUp(SignUpRequest request);

  // 로그인을 요청하고 성공 시 토큰 정보를 반환하는 기능
  Future<TokenInfo> login(LoginRequest request);

  // 로그아웃을 요청하는 기능
  Future<void> logout();
}

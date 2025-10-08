import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mongle_flutter/features/profile/domain/entities/user_profile.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  // 앱이 처음 시작되어 아직 인증 상태를 확인하지 못한 초기 상태
  const factory AuthState.initial() = _Initial;

  // 로그인, 회원가입 등 비동기 작업이 진행 중인 상태
  const factory AuthState.loading() = _Loading;

  // 로그인에 성공하여 인증된 상태
  const factory AuthState.authenticated(UserProfile user) = _Authenticated;

  // 로그아웃되었거나, 로그인에 실패했거나, 토큰이 없는 비인증 상태
  const factory AuthState.unauthenticated({String? message}) = _Unauthenticated;
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_code_response.freezed.dart';
part 'verify_code_response.g.dart';

/// 인증 코드 확인 응답
@freezed
abstract class VerifyCodeResponse with _$VerifyCodeResponse {
  const factory VerifyCodeResponse({required String verificationToken}) =
      _VerifyCodeResponse;

  factory VerifyCodeResponse.fromJson(Map<String, dynamic> json) =>
      _$VerifyCodeResponseFromJson(json);
}

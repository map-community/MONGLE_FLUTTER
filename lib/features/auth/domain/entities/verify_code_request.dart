import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_code_request.freezed.dart';
part 'verify_code_request.g.dart';

/// 인증 코드 확인 요청
@freezed
abstract class VerifyCodeRequest with _$VerifyCodeRequest {
  const factory VerifyCodeRequest({
    required String email,
    required String verificationCode,
  }) = _VerifyCodeRequest;

  factory VerifyCodeRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyCodeRequestFromJson(json);
}

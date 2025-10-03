import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_request.freezed.dart';
part 'sign_up_request.g.dart';

@freezed
abstract class SignUpRequest with _$SignUpRequest {
  @JsonSerializable()
  const factory SignUpRequest({
    required String email,
    required String password,
    required String nickname,
    String? profileImageKey, // 필수가 아닌 값은 nullable(?)로 선언
  }) = _SignUpRequest;

  factory SignUpRequest.fromJson(Map<String, dynamic> json) =>
      _$SignUpRequestFromJson(json);
}

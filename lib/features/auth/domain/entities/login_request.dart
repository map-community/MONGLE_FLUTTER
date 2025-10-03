import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_request.freezed.dart';
part 'login_request.g.dart';

@freezed
abstract class LoginRequest with _$LoginRequest {
  @JsonSerializable(
    // Java의 camelCase 필드명을 그대로 사용하므로 특별한 설정은 필요 없습니다.
    // toJson 생성 시 null 필드를 무시하려면 includeIfNull: false 추가 가능
  )
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  // 이 모델은 서버로 '보내기만' 할 것이므로 fromJson은 필요 없습니다.
}

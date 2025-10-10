// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_up_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SignUpRequest _$SignUpRequestFromJson(Map<String, dynamic> json) =>
    _SignUpRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      nickname: json['nickname'] as String,
      verificationToken: json['verificationToken'] as String,
      profileImageKey: json['profileImageKey'] as String?,
    );

Map<String, dynamic> _$SignUpRequestToJson(_SignUpRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'nickname': instance.nickname,
      'verificationToken': instance.verificationToken,
      'profileImageKey': instance.profileImageKey,
    };

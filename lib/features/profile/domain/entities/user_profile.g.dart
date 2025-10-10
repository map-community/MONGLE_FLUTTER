// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  nickname: json['nickname'] as String,
  email: json['email'] as String,
  profileImageUrl: json['profileImageUrl'] as String?,
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'nickname': instance.nickname,
      'email': instance.email,
      'profileImageUrl': instance.profileImageUrl,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'author.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Author _$AuthorFromJson(Map<String, dynamic> json) => _Author(
  id: json['id'] as String?,
  nickname: json['nickname'] as String,
  profileImageUrl: json['profileImageUrl'] as String?,
);

Map<String, dynamic> _$AuthorToJson(_Author instance) => <String, dynamic>{
  'id': instance.id,
  'nickname': instance.nickname,
  'profileImageUrl': instance.profileImageUrl,
};

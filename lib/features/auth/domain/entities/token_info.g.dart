// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TokenInfo _$TokenInfoFromJson(Map<String, dynamic> json) => _TokenInfo(
  tokenType: json['tokenType'] as String,
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
  accessTokenExpirationMillis: (json['accessTokenExpirationMillis'] as num)
      .toInt(),
  refreshTokenExpirationMillis: (json['refreshTokenExpirationMillis'] as num)
      .toInt(),
);

Map<String, dynamic> _$TokenInfoToJson(_TokenInfo instance) =>
    <String, dynamic>{
      'tokenType': instance.tokenType,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'accessTokenExpirationMillis': instance.accessTokenExpirationMillis,
      'refreshTokenExpirationMillis': instance.refreshTokenExpirationMillis,
    };

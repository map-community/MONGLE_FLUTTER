// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reaction_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReactionResponse _$ReactionResponseFromJson(Map<String, dynamic> json) =>
    _ReactionResponse(
      likeCount: (json['likeCount'] as num).toInt(),
      dislikeCount: (json['dislikeCount'] as num).toInt(),
    );

Map<String, dynamic> _$ReactionResponseToJson(_ReactionResponse instance) =>
    <String, dynamic>{
      'likeCount': instance.likeCount,
      'dislikeCount': instance.dislikeCount,
    };

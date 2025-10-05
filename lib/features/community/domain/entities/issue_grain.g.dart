// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issue_grain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IssueGrain _$IssueGrainFromJson(Map<String, dynamic> json) => _IssueGrain(
  postId: json['postId'] as String,
  author: Author.fromJson(json['author'] as Map<String, dynamic>),
  content: json['content'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  photoUrls:
      (json['photoUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  videoUrls:
      (json['videoUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  likeCount: (_readLikeCount(json, 'likeCount') as num).toInt(),
  dislikeCount: (_readDislikeCount(json, 'dislikeCount') as num).toInt(),
  commentCount: (json['commentCount'] as num).toInt(),
  viewCount: (json['viewCount'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  myReaction:
      $enumDecodeNullable(_$ReactionTypeEnumMap, json['myReaction']) ?? null,
);

Map<String, dynamic> _$IssueGrainToJson(_IssueGrain instance) =>
    <String, dynamic>{
      'postId': instance.postId,
      'author': instance.author,
      'content': instance.content,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'photoUrls': instance.photoUrls,
      'videoUrls': instance.videoUrls,
      'likeCount': instance.likeCount,
      'dislikeCount': instance.dislikeCount,
      'commentCount': instance.commentCount,
      'viewCount': instance.viewCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'myReaction': _$ReactionTypeEnumMap[instance.myReaction],
    };

const _$ReactionTypeEnumMap = {
  ReactionType.LIKE: 'LIKE',
  ReactionType.DISLIKE: 'DISLIKE',
};

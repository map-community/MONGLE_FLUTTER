// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issue_grain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IssueGrain _$IssueGrainFromJson(Map<String, dynamic> json) => _IssueGrain(
  id: json['id'] as String,
  author: Author.fromJson(json['author'] as Map<String, dynamic>),
  content: json['content'] as String,
  photoUrls:
      (json['photoUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  createdAt: DateTime.parse(json['createdAt'] as String),
  viewCount: (json['viewCount'] as num).toInt(),
  likeCount: (json['likeCount'] as num).toInt(),
  dislikeCount: (json['dislikeCount'] as num).toInt(),
  commentCount: (json['commentCount'] as num).toInt(),
);

Map<String, dynamic> _$IssueGrainToJson(_IssueGrain instance) =>
    <String, dynamic>{
      'id': instance.id,
      'author': instance.author,
      'content': instance.content,
      'photoUrls': instance.photoUrls,
      'createdAt': instance.createdAt.toIso8601String(),
      'viewCount': instance.viewCount,
      'likeCount': instance.likeCount,
      'dislikeCount': instance.dislikeCount,
      'commentCount': instance.commentCount,
    };

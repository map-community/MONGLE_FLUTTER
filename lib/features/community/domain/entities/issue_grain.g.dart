// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issue_grain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IssueGrain _$IssueGrainFromJson(Map<String, dynamic> json) => _IssueGrain(
  postId: json['post_id'] as String,
  author: Author.fromJson(json['author'] as Map<String, dynamic>),
  content: json['content'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  photoUrls:
      (json['photoUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  likeCount: (json['like_count'] as num).toInt(),
  dislikeCount: (json['dislike_count'] as num).toInt(),
  commentCount: (json['comment_count'] as num).toInt(),
  viewCount: (json['view_count'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$IssueGrainToJson(_IssueGrain instance) =>
    <String, dynamic>{
      'post_id': instance.postId,
      'author': instance.author,
      'content': instance.content,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'photoUrls': instance.photoUrls,
      'like_count': instance.likeCount,
      'dislike_count': instance.dislikeCount,
      'comment_count': instance.commentCount,
      'view_count': instance.viewCount,
      'created_at': instance.createdAt.toIso8601String(),
    };

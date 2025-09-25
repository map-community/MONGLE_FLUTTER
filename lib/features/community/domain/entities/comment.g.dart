// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Comment _$CommentFromJson(Map<String, dynamic> json) => _Comment(
  commentId: json['comment_id'] as String,
  content: json['content'] as String,
  author: Author.fromJson(json['author'] as Map<String, dynamic>),
  likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
  dislikeCount: (json['dislike_count'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  isDeleted: json['isDeleted'] as bool? ?? false,
  isAuthor: json['isAuthor'] as bool? ?? false,
  replies:
      (json['replies'] as List<dynamic>?)
          ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$CommentToJson(_Comment instance) => <String, dynamic>{
  'comment_id': instance.commentId,
  'content': instance.content,
  'author': instance.author,
  'like_count': instance.likeCount,
  'dislike_count': instance.dislikeCount,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'isDeleted': instance.isDeleted,
  'isAuthor': instance.isAuthor,
  'replies': instance.replies,
};

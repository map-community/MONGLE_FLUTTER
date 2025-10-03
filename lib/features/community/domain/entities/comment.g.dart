// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Comment _$CommentFromJson(Map<String, dynamic> json) => _Comment(
  commentId: json['commentId'] as String,
  content: json['content'] as String,
  author: Author.fromJson(json['author'] as Map<String, dynamic>),
  likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
  dislikeCount: (json['dislikeCount'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  isDeleted: json['isDeleted'] as bool? ?? false,
  isAuthor: json['isAuthor'] as bool? ?? false,
  replies:
      (json['replies'] as List<dynamic>?)
          ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$CommentToJson(_Comment instance) => <String, dynamic>{
  'commentId': instance.commentId,
  'content': instance.content,
  'author': instance.author,
  'likeCount': instance.likeCount,
  'dislikeCount': instance.dislikeCount,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'isDeleted': instance.isDeleted,
  'isAuthor': instance.isAuthor,
  'replies': instance.replies,
};

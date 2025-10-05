// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Comment _$CommentFromJson(Map<String, dynamic> json) => _Comment(
  commentId: _readCommentId(json, 'commentId') as String,
  content: json['content'] as String,
  author: Author.fromJson(json['author'] as Map<String, dynamic>),
  likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
  dislikeCount: (json['dislikeCount'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  isAuthor: json['isAuthor'] as bool? ?? false,
  isDeleted: json['isDeleted'] as bool? ?? false,
  hasReplies: json['hasReplies'] as bool? ?? false,
  replies:
      (json['replies'] as List<dynamic>?)
          ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  myReaction: $enumDecodeNullable(_$ReactionTypeEnumMap, json['myReaction']),
);

Map<String, dynamic> _$CommentToJson(_Comment instance) => <String, dynamic>{
  'commentId': instance.commentId,
  'content': instance.content,
  'author': instance.author,
  'likeCount': instance.likeCount,
  'dislikeCount': instance.dislikeCount,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'isAuthor': instance.isAuthor,
  'isDeleted': instance.isDeleted,
  'hasReplies': instance.hasReplies,
  'replies': instance.replies,
  'myReaction': _$ReactionTypeEnumMap[instance.myReaction],
};

const _$ReactionTypeEnumMap = {
  ReactionType.LIKE: 'LIKE',
  ReactionType.DISLIKE: 'DISLIKE',
};

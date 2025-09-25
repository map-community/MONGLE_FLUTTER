// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_comments.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaginatedComments _$PaginatedCommentsFromJson(Map<String, dynamic> json) =>
    _PaginatedComments(
      comments:
          (json['values'] as List<dynamic>?)
              ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      nextCursor: json['nextCursor'] as String?,
      hasNext: json['hasNext'] as bool? ?? true,
      replyingTo: json['replyingTo'] == null
          ? null
          : Comment.fromJson(json['replyingTo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PaginatedCommentsToJson(_PaginatedComments instance) =>
    <String, dynamic>{
      'values': instance.comments,
      'nextCursor': instance.nextCursor,
      'hasNext': instance.hasNext,
      'replyingTo': instance.replyingTo,
    };

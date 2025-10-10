// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_posts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaginatedPosts _$PaginatedPostsFromJson(Map<String, dynamic> json) =>
    _PaginatedPosts(
      posts:
          (json['posts'] as List<dynamic>?)
              ?.map((e) => IssueGrain.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      nextCursor: json['nextCursor'] as String?,
      hasNext: json['hasNext'] as bool? ?? false,
    );

Map<String, dynamic> _$PaginatedPostsToJson(_PaginatedPosts instance) =>
    <String, dynamic>{
      'posts': instance.posts,
      'nextCursor': instance.nextCursor,
      'hasNext': instance.hasNext,
    };

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mongle_flutter/features/community/domain/entities/issue_grain.dart';

part 'paginated_posts.freezed.dart';
part 'paginated_posts.g.dart';

@freezed
abstract class PaginatedPosts with _$PaginatedPosts {
  const factory PaginatedPosts({
    // API 응답의 'posts' 키와 매칭
    @Default([]) List<IssueGrain> posts,
    String? nextCursor,
    @Default(false) bool hasNext,
  }) = _PaginatedPosts;

  factory PaginatedPosts.fromJson(Map<String, dynamic> json) =>
      _$PaginatedPostsFromJson(json);
}

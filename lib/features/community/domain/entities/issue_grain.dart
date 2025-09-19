import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mongle_flutter/features/community/domain/entities/author.dart'; // 가상의 유저 모델

part 'issue_grain.freezed.dart';
part 'issue_grain.g.dart';

@freezed
abstract class IssueGrain with _$IssueGrain {
  const factory IssueGrain({
    @JsonKey(name: 'post_id') required String postId,
    required Author author, // 작성자 정보 (User 모델과 결합)
    required String content,
    required double latitude,
    required double longitude,
    @Default([]) List<String> photoUrls, // 이미지 URL 목록
    @JsonKey(name: 'like_count') required int likeCount,
    @JsonKey(name: 'dislike_count') required int dislikeCount,
    @JsonKey(name: 'comment_count') required int commentCount,
    @JsonKey(name: 'view_count') required int viewCount,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _IssueGrain;

  factory IssueGrain.fromJson(Map<String, dynamic> json) =>
      _$IssueGrainFromJson(json);
}

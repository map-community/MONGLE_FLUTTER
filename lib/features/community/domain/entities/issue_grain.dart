import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mongle_flutter/features/community/domain/entities/author.dart';
import 'package:mongle_flutter/features/community/domain/entities/reaction_models.dart'; // 가상의 유저 모델

part 'issue_grain.freezed.dart';
part 'issue_grain.g.dart';

@freezed
abstract class IssueGrain with _$IssueGrain {
  const factory IssueGrain({
    required String postId,
    required Author author, // 작성자 정보 (User 모델과 결합)
    required String content,
    required double latitude,
    required double longitude,
    @Default([]) List<String> photoUrls, // 이미지 URL 목록
    @Default([]) List<String> videoUrls,
    required int likeCount,
    required int dislikeCount,
    required int commentCount,
    required int viewCount,
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default(null) ReactionType? myReaction,
  }) = _IssueGrain;

  factory IssueGrain.fromJson(Map<String, dynamic> json) =>
      _$IssueGrainFromJson(json);
}

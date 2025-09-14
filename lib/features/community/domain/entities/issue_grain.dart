import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mongle_flutter/features/community/domain/entities/author.dart'; // 가상의 유저 모델

part 'issue_grain.freezed.dart';
part 'issue_grain.g.dart';

@freezed
class IssueGrain with _$IssueGrain {
  const factory IssueGrain({
    required String id,
    required Author author, // 작성자 정보 (User 모델과 결합)
    required String content,
    @Default([]) List<String> photoUrls, // 이미지 URL 목록
    required DateTime createdAt,
    required int viewCount,
    required int likeCount,
    required int dislikeCount,
    required int commentCount,
  }) = _IssueGrain;

  factory IssueGrain.fromJson(Map<String, dynamic> json) =>
      _$IssueGrainFromJson(json);
}

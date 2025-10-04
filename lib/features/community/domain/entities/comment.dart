import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mongle_flutter/features/community/domain/entities/author.dart';

part 'comment.freezed.dart';
part 'comment.g.dart';

// json에서 'commentId' 키를 먼저 찾고, 없으면 'replyId' 키를 대신 사용합니다.
Object? _readCommentId(Map json, String key) =>
    json['commentId'] ?? json['replyId'];

@freezed
abstract class Comment with _$Comment {
  const factory Comment({
    @JsonKey(readValue: _readCommentId) required String commentId,
    required String content,
    required Author author,
    @Default(0) int likeCount,
    @Default(0) int dislikeCount,
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default(false) bool isAuthor,
    @Default(false) bool isDeleted,
    @Default(false) bool hasReplies,
    @Default([]) List<Comment> replies,
  }) = _Comment;

  // Entity가 직접 fromJson 팩토리 메서드를 가집니다.
  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mongle_flutter/features/community/domain/entities/author.dart';

part 'comment.freezed.dart';
part 'comment.g.dart';

@freezed
abstract class Comment with _$Comment {
  const factory Comment({
    required String commentId,
    required String content,

    // Author 객체를 직접 포함합니다.
    // json_serializable이 author.dart의 fromJson을 자동으로 호출해줍니다.
    required Author author,

    @Default(0) int likeCount,
    @Default(0) int dislikeCount,

    required DateTime createdAt,
    DateTime? updatedAt,

    @Default(false) bool isDeleted,
    @Default(false) bool isAuthor,

    @Default([]) List<Comment> replies,
  }) = _Comment;

  // Entity가 직접 fromJson 팩토리 메서드를 가집니다.
  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);
}

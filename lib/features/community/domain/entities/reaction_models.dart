import 'package:freezed_annotation/freezed_annotation.dart';

part 'reaction_models.freezed.dart';
part 'reaction_models.g.dart';

// 서버 API의 'LIKE', 'DISLIKE'와 일치하는 enum
enum ReactionType { LIKE, DISLIKE }

// 서버에서 { "likeCount": 10, "dislikeCount": 2 } 형태로 응답을 보내줄 것이므로,
// 이 JSON을 담을 데이터 클래스(DTO)를 정의합니다.
@freezed
abstract class ReactionResponse with _$ReactionResponse {
  const factory ReactionResponse({
    required int likeCount,
    required int dislikeCount,
  }) = _ReactionResponse;

  factory ReactionResponse.fromJson(Map<String, dynamic> json) =>
      _$ReactionResponseFromJson(json);
}

@freezed
abstract class ReactionState with _$ReactionState {
  const factory ReactionState({
    required int likeCount,
    required int dislikeCount,
    ReactionType? myReaction,
    @Default(false) bool isUpdating,
  }) = _ReactionState;
}

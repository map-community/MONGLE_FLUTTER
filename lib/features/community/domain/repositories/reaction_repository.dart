import 'package:mongle_flutter/features/community/domain/entities/reaction_models.dart';

// '반응' 데이터 통신을 위한 계약서입니다.
abstract class ReactionRepository {
  // targetType은 'posts' 또는 'comments'가 될 수 있습니다.
  // reactionType은 사용자가 누른 버튼의 종류입니다.
  // 성공 시, 서버로부터 업데이트된 최종 카운트를 ReactionResponse 객체로 받습니다.
  Future<ReactionResponse> updateReaction({
    required String targetType,
    required String targetId,
    required ReactionType reactionType,
  });
}

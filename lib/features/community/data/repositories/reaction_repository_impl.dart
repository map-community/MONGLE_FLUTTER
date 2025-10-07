import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/core/constants/api_constants.dart';
import 'package:mongle_flutter/core/dio/dio_provider.dart';
import 'package:mongle_flutter/features/auth/providers/user_provider.dart';
import 'package:mongle_flutter/features/community/domain/entities/reaction_models.dart';
import 'package:mongle_flutter/features/community/domain/repositories/reaction_repository.dart';

// 1. 이 구현체를 앱 전역에서 사용할 수 있도록 Provider로 만듭니다.
final reactionRepositoryProvider = Provider<ReactionRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ReactionRepositoryImpl(ref, dio);
});

// 2. '계약서(ReactionRepository)'를 실제로 '구현'하는 클래스
class ReactionRepositoryImpl implements ReactionRepository {
  final Ref _ref;
  final Dio _dio;

  ReactionRepositoryImpl(this._ref, this._dio);

  @override
  Future<ReactionResponse> updateReaction({
    required String targetType,
    required String targetId,
    required ReactionType reactionType,
  }) async {
    // 현재 로그인한 사용자 ID를 가져옵니다. (비동기)
    final memberId = await _ref.read(currentMemberIdProvider.future);
    if (memberId == null) {
      // 로그인이 되어있지 않으면 에러를 발생시켜 로직을 중단합니다.
      throw Exception('좋아요/싫어요를 하려면 로그인이 필요합니다.');
    }

    try {
      // 1단계에서 만든 ApiConstants.reaction 함수로 URL을 동적으로 생성합니다.
      final response = await _dio.post(
        ApiConstants.reaction(targetType, targetId),
        data: {
          // 서버는 reactionType을 enum의 이름 그대로(예: "LIKE") 받습니다.
          'reactionType': reactionType.name,
        },
      );

      // 서버 응답(JSON)을 ReactionResponse 객체로 변환하여 반환합니다.
      return ReactionResponse.fromJson(response.data);
    } catch (e) {
      // Dio 에러 또는 기타 예외가 발생하면 그대로 상위로 던져서
      // StateNotifier가 처리하도록 합니다.
      rethrow;
    }
  }
}

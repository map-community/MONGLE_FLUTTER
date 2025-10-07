import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ Ref를 사용하기 위해 import
import 'package:mongle_flutter/core/constants/api_constants.dart';
import 'package:mongle_flutter/features/auth/providers/user_provider.dart'; // ✅ 사용자 ID를 가져오기 위해 import
import 'package:mongle_flutter/features/community/domain/repositories/block_repository.dart';

class BlockRepositoryImpl implements BlockRepository {
  // ✅ Ref와 Dio를 모두 주입받도록 수정
  final Ref _ref;
  final Dio _dio;

  BlockRepositoryImpl(this._ref, this._dio);

  // ✅ 현재 사용자 ID를 가져오는 비공개 헬퍼 메서드
  Future<String> _getRequiredMemberId() async {
    // currentMemberIdProvider를 통해 로그인된 사용자의 ID를 가져옵니다.
    final memberId = await _ref.read(currentMemberIdProvider.future);
    if (memberId == null) {
      throw Exception('로그인이 필요합니다.');
    }
    return memberId;
  }

  @override
  Future<void> blockUser(String userId) async {
    // ✅ 헬퍼 메서드를 호출하여 memberId를 가져옵니다.
    final memberId = await _getRequiredMemberId();
    // ✅ queryParameters에 memberId를 추가합니다.
    await _dio.post(
      ApiConstants.blockUser(userId),
      queryParameters: {'memberId': memberId},
    );
  }

  @override
  Future<void> unblockUser(String userId) async {
    final memberId = await _getRequiredMemberId();
    // ✅ queryParameters에 memberId를 추가합니다.
    await _dio.delete(
      ApiConstants.blockUser(userId),
      queryParameters: {'memberId': memberId},
    );
  }

  @override
  Future<List<String>> getBlockedUserIds() async {
    final memberId = await _getRequiredMemberId();
    // ✅ queryParameters에 memberId를 추가합니다.
    final response = await _dio.get(
      ApiConstants.myBlockedUsers,
      queryParameters: {'memberId': memberId},
    );
    return List<String>.from(response.data);
  }
}

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

  @override
  Future<void> blockUser(String userId) async {
    await _dio.post(ApiConstants.blockUser(userId));
  }

  @override
  Future<void> unblockUser(String userId) async {
    await _dio.delete(ApiConstants.blockUser(userId));
  }

  @override
  Future<List<String>> getBlockedUserIds() async {
    final response = await _dio.get(ApiConstants.myBlockedUsers);
    return List<String>.from(response.data);
  }
}

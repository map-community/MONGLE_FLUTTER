import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/core/dio/dio_provider.dart';
import 'package:mongle_flutter/features/auth/providers/user_provider.dart';
import 'package:mongle_flutter/features/community/data/repositories/report_repository_impl.dart';
import 'package:mongle_flutter/features/community/domain/entities/report_models.dart';
import 'package:mongle_flutter/features/community/domain/repositories/report_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 이 Provider는 수정할 필요 없습니다.
final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepositoryImpl(ref.watch(dioProvider));
});

// ✅ [수정] AsyncNotifierProvider -> StateNotifierProvider로 되돌립니다.
final reportedContentProvider =
    StateNotifierProvider.autoDispose<
      ReportedContentNotifier,
      List<ReportedContent>
    >((ref) {
      ref.watch(currentMemberIdProvider);

      // 1. Notifier 인스턴스를 생성할 때 ref를 전달합니다.
      final notifier = ReportedContentNotifier(ref);
      // 2. 생성된 인스턴스의 init() 메서드를 호출하여 데이터를 비동기적으로 불러오게 합니다.
      notifier.init();
      return notifier;
    });

/// '내가 신고한 콘텐츠 ID 목록'을 관리하는 Notifier입니다.
class ReportedContentNotifier extends StateNotifier<List<ReportedContent>> {
  final Ref _ref; // ✅ ref를 멤버 변수로 가집니다.
  static const _storageKeyPrefix = 'reported_content_list_';

  // ✅ 생성자에서 ref를 받고, 초기 상태는 무조건 빈 리스트로 시작합니다.
  ReportedContentNotifier(this._ref) : super([]);

  /// Notifier가 처음 생성될 때 저장된 데이터를 비동기적으로 불러오는 초기화 메서드
  Future<void> init() async {
    // ref를 통해 현재 로그인한 사용자 ID를 가져옵니다.
    final memberId = _ref.read(currentMemberIdProvider).valueOrNull;
    if (memberId == null) {
      state = []; // 로그아웃 상태면 상태를 비웁니다.
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final key = '$_storageKeyPrefix$memberId'; // 사용자별 고유 키

    final savedList = prefs.getStringList(key);

    if (savedList != null) {
      final loadedContent = savedList
          .map((jsonString) => ReportedContent.fromJson(jsonDecode(jsonString)))
          .toList();
      state = loadedContent; // 상태를 업데이트합니다.
    }
  }

  /// 신고된 콘텐츠를 목록에 추가하고, 디바이스에 저장합니다.
  Future<void> addReportedContent({
    required String contentId,
    required ReportContentType contentType,
  }) async {
    final newItem = ReportedContent(id: contentId, type: contentType);
    if (state.contains(newItem)) return;

    state = [...state, newItem];
    await _saveStateToDisk();
  }

  /// 현재 상태를 디바이스에 저장하는 비공개 헬퍼 메서드
  Future<void> _saveStateToDisk() async {
    final memberId = _ref.read(currentMemberIdProvider).valueOrNull;
    if (memberId == null) return; // 로그아웃 상태면 저장하지 않습니다.

    final prefs = await SharedPreferences.getInstance();
    final key = '$_storageKeyPrefix$memberId';

    final listToSave = state.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(key, listToSave);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/core/dio/dio_provider.dart';
import 'package:mongle_flutter/features/community/data/repositories/fake_report_repository_impl.dart';
import 'package:mongle_flutter/features/community/data/repositories/report_repository_impl.dart';
import 'package:mongle_flutter/features/community/domain/entities/report_models.dart';
import 'package:mongle_flutter/features/community/domain/repositories/report_repository.dart';

// 1. [서비스 제공] ReportRepository의 구현체(Fake)를 제공하는 Provider
// "ReportRepository 주세요" 라고 요청하면 FakeReportRepositoryImpl 인스턴스를 반환합니다.
final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  // return FakeReportRepositoryImpl();
  return ReportRepositoryImpl(ref.watch(dioProvider));
});

// 2. [상태 관리 및 제공] '사용자가 신고해서 숨김 처리된' 콘텐츠 ID 목록을 관리하는 Provider
// 이 Provider의 목적은 오직 '즉시 숨김' UI를 구현하는 것입니다.
final reportedContentProvider =
    StateNotifierProvider<ReportedContentNotifier, List<ReportedContent>>((
      ref,
    ) {
      return ReportedContentNotifier();
    });

/// '내가 신고한 콘텐츠 ID 목록'이라는 상태(State)와
/// 그 상태를 변경하는 로직(Notifier)을 캡슐화한 클래스입니다.
class ReportedContentNotifier extends StateNotifier<List<ReportedContent>> {
  // 초기 상태는 빈 리스트([])입니다.
  ReportedContentNotifier() : super([]);

  /// 신고된 콘텐츠를 목록에 추가합니다.
  void addReportedContent({
    required String contentId,
    required ReportContentType contentType,
  }) {
    final newItem = ReportedContent(id: contentId, type: contentType);

    if (state.contains(newItem)) return;

    state = [...state, newItem];
    print(
      '[ReportedContentProvider] Added $newItem to hide list. Current list: $state',
    );
  }
}

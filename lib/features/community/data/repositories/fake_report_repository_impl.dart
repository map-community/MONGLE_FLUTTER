import 'package:mongle_flutter/features/community/domain/entities/report_models.dart';
import 'package:mongle_flutter/features/community/domain/repositories/report_repository.dart';

// ReportRepository 인터페이스의 규칙을 따르는 가짜 구현체 클래스입니다.
class FakeReportRepositoryImpl implements ReportRepository {
  @override
  Future<void> reportContent({
    required String contentId,
    required ReportContentType contentType,
    required ReportReason reason,
    String? description,
  }) async {
    // 실제 서버와 통신하는 것처럼 0.3초의 딜레이를 줍니다.
    await Future.delayed(const Duration(milliseconds: 300));

    // --- 가짜 서버 로그 ---
    // 프론트엔드에서 어떤 정보가 넘어왔는지 콘솔에 출력하여 확인합니다.
    print('--- 📝 New Content Report Received ---');
    print('✅ Content ID: $contentId');
    print(
      '✅ Content Type: ${contentType.name}',
    ); // .name을 통해 Enum의 이름을 문자열로 가져옵니다.
    print('✅ Reason: ${reason.name}');

    // 상세 설명이 있는 경우에만 출력합니다.
    if (description != null && description.isNotEmpty) {
      print('✅ Description: $description');
    }

    print('------------------------------------');
  }
}

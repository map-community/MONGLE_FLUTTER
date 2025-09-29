import 'package:mongle_flutter/features/community/domain/entities/report_models.dart';

/// '콘텐츠 신고'와 관련된 데이터 통신 규칙을 정의하는 추상 클래스(인터페이스)입니다.
abstract class ReportRepository {
  /// 특정 콘텐츠를 지정된 사유로 신고합니다.
  ///
  /// [contentId]는 신고할 게시물 또는 댓글의 고유 ID입니다.
  /// [contentType]은 신고 대상이 게시물인지 댓글인지 구분하는 Enum 값입니다.
  /// [reason]은 사용자가 선택한 신고 사유 Enum 값입니다.
  /// [description]은 사용자가 추가로 입력한 상세 내용(선택 사항)입니다.
  Future<void> reportContent({
    required String contentId,
    required ReportContentType contentType,
    required ReportReason reason,
    String? description,
  });
}

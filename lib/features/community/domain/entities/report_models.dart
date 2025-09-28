import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_models.freezed.dart'; // freezed가 생성할 파일

// 신고 대상의 종류
enum ReportContentType { POST, COMMENT }

// 신고 사유
enum ReportReason {
  SPAM, // 스팸 또는 광고
  ABUSE, // 욕설 또는 비방
  PORNOGRAPHY, // 음란물
  ILLEGAL, // 불법 정보
  INAPPROPRIATE, // 기타 부적절한 콘텐츠
}

@freezed
abstract class ReportedContent with _$ReportedContent {
  const factory ReportedContent({
    required String id,
    required ReportContentType type,
  }) = _ReportedContent;
}

extension ReportReasonExtension on ReportReason {
  // 'korean'이라는 이름의 게터(getter)를 추가합니다.
  String get korean {
    switch (this) {
      case ReportReason.SPAM:
        return '스팸 또는 광고';
      case ReportReason.ABUSE:
        return '욕설 또는 비방';
      case ReportReason.PORNOGRAPHY:
        return '음란물 또는 성희롱';
      case ReportReason.ILLEGAL:
        return '불법 정보';
      case ReportReason.INAPPROPRIATE:
        return '기타 부적절한 콘텐츠';
    }
  }
}

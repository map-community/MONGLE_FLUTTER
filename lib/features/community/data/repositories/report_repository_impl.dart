import 'package:dio/dio.dart';
import 'package:mongle_flutter/core/constants/api_constants.dart';
import 'package:mongle_flutter/features/community/domain/entities/report_models.dart';
import 'package:mongle_flutter/features/community/domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final Dio _dio;

  ReportRepositoryImpl(this._dio);

  @override
  Future<void> reportContent({
    required String contentId,
    required ReportContentType contentType,
    required ReportReason reason,
  }) async {
    try {
      // Dio를 사용하여 백엔드에 POST 요청을 보냅니다.
      await _dio.post(
        ApiConstants.reports,
        data: {
          'targetId': contentId,
          // enum을 서버가 이해하는 문자열로 변환합니다. (예: ReportContentType.POST -> "POST")
          'targetType': contentType.name,
          'reason': reason.name,
        },
      );
    } catch (e) {
      // 에러 발생 시 상위로 던져서 UI단에서 처리할 수 있도록 합니다.
      rethrow;
    }
  }
}

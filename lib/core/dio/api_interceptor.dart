import 'package:dio/dio.dart';

// dio를 위한 Custom Interceptor
class ApiInterceptor extends Interceptor {
  // 1. 요청을 보내기 전
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 요청 전 특별히 할 작업이 있다면 여기에 추가합니다. (예: 토큰 추가)
    // 지금 단계에서는 비워둡니다.
    super.onRequest(options, handler);
  }

  // 2. 응답을 받은 후
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 서버 응답 데이터가 Map 형태이고, 'code'와 'data' 키를 포함하는지 확인
    if (response.data is Map<String, dynamic> &&
        response.data.containsKey('code') &&
        response.data.containsKey('data')) {
      final String code = response.data['code'];
      final dynamic data = response.data['data'];

      if (code == 'SUCCESS') {
        // 성공적인 응답이라면, 'ApiResponse' 껍데기를 벗기고 실제 데이터('data' 필드)만 넘겨줍니다.
        response.data = data;
      } else {
        // 서버가 에러 코드를 보냈다면, DioError를 발생시켜 dio의 에러 처리 로직을 타게 합니다.
        // 좀 더 정교한 에러 처리를 위해 커스텀 에러 클래스를 만들 수도 있습니다.
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Unknown error',
        );
      }
    }
    super.onResponse(response, handler);
  }

  // 3. 에러가 발생했을 때
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 에러 발생 시 특별히 할 작업이 있다면 여기에 추가합니다. (예: 토큰 재발급)
    // 지금 단계에서는 비워둡니다.
    super.onError(err, handler);
  }
}

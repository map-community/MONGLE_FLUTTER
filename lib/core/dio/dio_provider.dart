import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/core/dio/api_interceptor.dart';

// 앱 전역에서 사용할 dio 인스턴스를 제공하는 Provider
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();

  // .env 파일에서 서버의 기본 URL을 불러옵니다.
  // 나중에 http -> https로 바꿀 때 여기만 수정하면 됩니다.
  final baseUrl = dotenv.env['API_BASE_URL'];

  dio.options = BaseOptions(
    baseUrl: baseUrl ?? 'http://localhost:8080', // .env 파일이 없을 경우를 대비한 기본값
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  );

  // 우리가 만든 ApiInterceptor를 dio에 추가합니다.
  // 이제 이 dio 인스턴스를 통해 나가는 모든 요청/응답은 ApiInterceptor를 거치게 됩니다.
  dio.interceptors.add(ApiInterceptor(ref));

  // (추가) 개발 중 로그를 확인하기 위해 LogInterceptor를 추가하면 편리합니다.
  dio.interceptors.add(
    LogInterceptor(
      responseBody: true, // 응답 본문을 로그에 출력
      requestBody: true, // 요청 본문을 로그에 출력
    ),
  );

  return dio;
});

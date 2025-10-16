import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/core/dio/api_interceptor.dart';

// dio_provider.dart
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();

  final baseUrl = dotenv.env['API_BASE_URL'];

  dio.options = BaseOptions(
    baseUrl: baseUrl ?? 'http://localhost:8080',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 8),
  );

  // ApiInterceptor 추가 (ref만 전달)
  dio.interceptors.add(ApiInterceptor(ref));

  dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

  return dio;
});

// 리프레시 토큰용 별도 Dio Provider
final refreshDioProvider = Provider<Dio>((ref) {
  final dio = Dio();

  final baseUrl = dotenv.env['API_BASE_URL'];

  dio.options = BaseOptions(
    baseUrl: baseUrl ?? 'http://localhost:8080',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 8),
  );

  // 리프레시용 Dio는 인터셉터 없음 (무한 루프 방지)
  dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

  return dio;
});

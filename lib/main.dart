// lib/main.dart

import 'dart:async'; // Future.timeout을 사용하기 위해 추가
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:mongle_flutter/core/navigation/router.dart';
import 'package:mongle_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // timeago 설정은 초기화 실패와 관계없이 항상 실행되어야 하므로 try 블록 밖으로 이동합니다.
  timeago.setLocaleMessages('ko', timeago.KoMessages());

  try {
    // 1. 실패 가능성이 있는 초기화 로직을 try 블록 안에 배치합니다.
    await dotenv.load(fileName: ".env");
    final naverMapClientId = dotenv.env['NAVER_MAP_CLIENT_ID'];

    if (naverMapClientId == null) {
      throw Exception("Naver Map Client ID가 .env 파일에 없습니다.");
    }

    // 2. 10초의 타임아웃(timeout)을 추가합니다.
    // 10초 안에 초기화가 완료되지 않으면 TimeoutException을 발생시켜 catch 블록으로 보냅니다.
    await FlutterNaverMap()
        .init(
          clientId: naverMapClientId,
          onAuthFailed: (ex) {
            print("Naver Map 인증 실패: $ex");
            // 인증 실패는 심각한 문제이므로 에러를 발생시켜 catch 블록에서 처리하도록 합니다.
            throw ex;
          },
        )
        .timeout(const Duration(seconds: 10));
  } catch (e) {
    // 3. 타임아웃을 포함한 모든 종류의 오류를 여기서 처리합니다.
    print("앱 초기화 중 오류 발생: $e");
    // 이 블록에서 오류 상황에 대한 추가적인 로깅이나 사용자 알림을 구현할 수 있습니다.
  } finally {
    // 4. 성공하든, 실패하든, finally 블록은 항상 실행됩니다.
    // 여기서 스플래시 화면을 제거하여 앱이 멈추는 현상을 근본적으로 방지합니다.
    FlutterNativeSplash.remove();
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final restartKey = ref.watch(appRestartTriggerProvider);

    return MaterialApp.router(
      key: ObjectKey(restartKey),
      routerConfig: router,
      title: '몽글 (MONGLE)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,

        // 👇 [추가] 앱의 모든 ElevatedButton에 적용될 전역 스타일
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // 파란색 배경
            foregroundColor: Colors.white, // 하얀색 글씨
            surfaceTintColor: Colors.blue, // Material 3 호환성
          ),
        ),
      ),
    );
  }
}

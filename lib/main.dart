// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:mongle_flutter/core/navigation/router.dart';
import 'package:mongle_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() async {
  // WidgetsBinding을 변수에 저장하여 재사용할 수 있도록 합니다.
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  //  네이티브 스플래시 스크린을 앱 초기화 전까지 유지하도록 설정합니다.
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // 1. runApp() 전에 Flutter 엔진과 위젯 바인딩이 준비되도록 보장합니다.
  // main 함수 상단에서 이미 호출되었으므로, 이 라인은 중복되어 제거해도 괜찮습니다.
  // WidgetsFlutterBinding.ensureInitialized();

  // 2. .env 파일을 로드합니다.
  await dotenv.load(fileName: ".env");
  final naverMapClientId = dotenv.env['NAVER_MAP_CLIENT_ID'];

  // 3. Naver Map SDK를 초기화합니다. Client ID는 .env 파일에서 안전하게 가져옵니다.
  await FlutterNaverMap().init(
    clientId: naverMapClientId!,
    onAuthFailed: (ex) {
      switch (ex) {
        case NQuotaExceededException(:final message):
          print("사용량 초과 (message: $message)");
          break;
        case NUnauthorizedClientException() ||
        NClientUnspecifiedException() ||
        NAnotherAuthFailedException():
          print("인증 실패: $ex");
          break;
      }
    },
  );

  timeago.setLocaleMessages('ko', timeago.KoMessages()); // 한글 메시지 설정
  // 모든 초기화가 끝난 후, runApp을 호출하기 직전에 스플래시 스크린을 제거합니다.
  FlutterNativeSplash.remove();
  runApp(
    // Riverpod를 앱 전체에서 사용하기 위해 ProviderScope로 감싸줍니다.
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch를 사용하여 routerProvider로부터 GoRouter 인스턴스를 가져옵니다.
    final router = ref.watch(routerProvider);

    // 🔥 로그아웃 시 이 값이 바뀌면서 전체 위젯 트리 재생성
    final restartKey = ref.watch(appRestartTriggerProvider);

    return MaterialApp.router(
      key: ObjectKey(restartKey), // 🔥 key 추가
      routerConfig: router,
      title: '몽글 (MONGLE)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
    );
  }
}
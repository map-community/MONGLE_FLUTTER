import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  // TODO: 추후 Firebase, Naver Map 등 비동기 초기화 로직 추가 예정

  runApp(
    // Riverpod를 앱 전체에서 사용하기 위해 ProviderScope로 감싸줍니다.
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // TODO: 추후 GoRouter 설정 연동 예정
      home: Scaffold(
        appBar: AppBar(title: const Text('몽글 (MONGLE)')),
        body: const Center(child: Text('프로젝트 기반 설정 완료!')),
      ),
    );
  }
}

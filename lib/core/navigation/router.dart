import 'package:go_router/go_router.dart';
import 'package:mongle_flutter/common/widgets/main_shell.dart';
import 'package:mongle_flutter/features/community/presentation/screens/cloud_screen.dart';
import 'package:mongle_flutter/features/feed/presentation/screens/feed_screen.dart';
import 'package:mongle_flutter/features/map/presentation/screens/map_screen.dart';
import 'package:mongle_flutter/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';

// GoRouter 설정을 앱 전역에서 사용할 수 있도록 인스턴스를 생성합니다.
final GoRouter router = GoRouter(
  // 앱이 처음 시작될 때 보여줄 경로를 지정합니다.
  initialLocation: '/map',

  // 경로 목록을 정의합니다.
  routes: [
    // MainShell은 하단 탭을 가지고 있으며, 그 안의 내용은 자식(child) 경로에 따라 바뀝니다.
    ShellRoute(
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      // ShellRoute 안에 포함될 자식 경로들을 정의합니다.
      routes: [
        GoRoute(
          path: '/map',
          builder: (context, state) => const MapScreen(),
          // ✅ 여기에 자식 경로(routes)를 추가합니다.
          routes: [
            GoRoute(
              // path에 슬래시(/)를 붙이지 않으면 자동으로 부모 경로 뒤에 붙습니다.
              // 즉, '/map' + 'cloud/:cloudId' = '/map/cloud/:cloudId' 가 됩니다.
              path: 'cloud/:cloudId',
              builder: (context, state) {
                // URL 경로에 있던 :cloudId 값을 여기서 추출할 수 있습니다.
                final cloudId = state.pathParameters['cloudId']!;

                // TODO: 2단계에서 'CloudScreen' 위젯을 만들어 이곳에 연결할 것입니다.
                // 지금은 라우팅이 잘 동작하는지 확인하기 위해 임시 위젯을 반환합니다.
                return CloudScreen(cloudId: cloudId);
              },
            ),
          ],
        ),
        GoRoute(path: '/feed', builder: (context, state) => const FeedScreen()),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);

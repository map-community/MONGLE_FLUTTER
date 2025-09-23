import 'package:go_router/go_router.dart';
import 'package:mongle_flutter/common/widgets/main_shell.dart';
import 'package:mongle_flutter/features/community/presentation/screens/cloud_screen.dart';
import 'package:mongle_flutter/features/community/presentation/screens/grain_detail_screen.dart';
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
          routes: [
            GoRoute(
              path: 'cloud/:cloudId',
              builder: (context, state) {
                final cloudId = state.pathParameters['cloudId']!;
                return CloudScreen(cloudId: cloudId);
              },
              // ✅ 2. 'cloud/:cloudId' 경로의 자식으로 새로운 경로를 추가합니다.
              routes: [
                GoRoute(
                  path:
                      'grain/:grainId', // 최종 경로: /map/cloud/:cloudId/grain/:grainId
                  builder: (context, state) {
                    final grainId = state.pathParameters['grainId']!;
                    return GrainDetailScreen(grainId: grainId);
                  },
                ),
              ],
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

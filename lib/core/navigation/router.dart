import 'package:go_router/go_router.dart';
import 'package:mongle_flutter/common/widgets/main_shell.dart';
import 'package:mongle_flutter/common/widgets/simple_info_screen.dart';
import 'package:mongle_flutter/core/constants/policy_strings.dart';
import 'package:mongle_flutter/features/community/presentation/screens/cloud_screen.dart';
import 'package:mongle_flutter/features/community/presentation/screens/grain_detail_screen.dart';
import 'package:mongle_flutter/features/feed/presentation/screens/feed_screen.dart';
import 'package:mongle_flutter/features/map/presentation/screens/map_screen.dart';
import 'package:mongle_flutter/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';

//  재사용 가능한 슬라이드 전환 효과 함수
// 이 함수는 Page를 반환하며, 내부에 애니메이션 효과를 정의합니다.
CustomTransitionPage<T> _buildSlideTransitionPage<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // 애니메이션이 뒤로가기(pop) 상태인지 확인합니다.
      final isPopping = animation.status == AnimationStatus.reverse;

      // 시작/끝 위치는 동일합니다.
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;

      // 애니메이션 방향에 따라 다른 커브를 적용합니다.
      // 들어올 때: 빠르게 시작 -> 느리게 끝 (easeOut)
      // 나갈 때: "빠르게 시작 -> 느리게 끝" 느낌을 주려면, 반대로 재생되는 애니메이션에는 easeIn 커브를 적용해야 합니다.
      final curve = isPopping ? Curves.easeInCubic : Curves.easeOutCubic;

      final tween = Tween(
        begin: begin,
        end: end,
      ).chain(CurveTween(curve: curve));
      final offsetAnimation = animation.drive(tween);

      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}

// GoRouter 설정을 앱 전역에서 사용할 수 있도록 인스턴스를 생성합니다.
final GoRouter router = GoRouter(
  // 앱이 처음 시작될 때 보여줄 경로를 지정합니다.
  initialLocation: '/map',

  routes: [
    // CloudScreen 경로를 이곳, ShellRoute와 같은 레벨로 이동시킵니다.
    GoRoute(
      path: '/cloud/:cloudId', // 경로를 '/map/cloud...' 에서 '/cloud...'로 변경
      pageBuilder: (context, state) {
        final cloudId = state.pathParameters['cloudId']!;
        return _buildSlideTransitionPage(
          context: context,
          state: state,
          child: CloudScreen(cloudId: cloudId),
        );
      },
      routes: [
        GoRoute(
          path: 'grain/:grainId',
          pageBuilder: (context, state) {
            final grainId = state.pathParameters['grainId']!;
            return _buildSlideTransitionPage(
              context: context,
              state: state,
              child: GrainDetailScreen(grainId: grainId),
            );
          },
        ),
      ],
    ),

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
          routes: [],
        ),
        GoRoute(path: '/feed', builder: (context, state) => const FeedScreen()),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
          routes: [
            GoRoute(
              path: 'privacy-policy', // -> /profile/privacy-policy
              builder: (context, state) => const SimpleInfoScreen(
                title: '개인정보처리방침',
                body: privacyPolicyMarkdown,
              ),
            ),
            GoRoute(
              path: 'terms-of-service', // -> /profile/terms-of-service
              builder: (context, state) => const SimpleInfoScreen(
                title: '이용약관',
                body: termsOfServiceMarkdown,
              ),
            ),
            GoRoute(
              path: 'contact', // -> /profile/contact
              builder: (context, state) => const SimpleInfoScreen(
                title: '문의하기',
                body: contactInfoMarkdown,
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);

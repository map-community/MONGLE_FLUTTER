import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mongle_flutter/common/widgets/main_shell.dart';
import 'package:mongle_flutter/common/widgets/simple_info_screen.dart';
import 'package:mongle_flutter/core/constants/policy_strings.dart';
import 'package:mongle_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:mongle_flutter/features/auth/presentation/providers/auth_state.dart';
import 'package:mongle_flutter/features/auth/presentation/screens/login_screen.dart';
import 'package:mongle_flutter/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:mongle_flutter/features/community/presentation/screens/cloud_screen.dart';
import 'package:mongle_flutter/features/community/presentation/screens/grain_detail_screen.dart';
import 'package:mongle_flutter/features/community/presentation/screens/write_grain_screen.dart';
import 'package:mongle_flutter/features/feed/presentation/screens/feed_screen.dart';
import 'package:mongle_flutter/features/map/presentation/screens/map_screen.dart';
import 'package:mongle_flutter/features/profile/presentation/screens/profile_screen.dart';

// Riverpod Provider의 상태 변화를 GoRouter에 알려주기 위한 헬퍼 클래스
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// GoRouter 인스턴스를 앱 전역에 제공하는 Riverpod Provider입니다.
final routerProvider = Provider<GoRouter>((ref) {
  // ❗️ [핵심] 인증 상태가 변경될 때마다 라우팅 규칙을 재검토하도록 설정합니다.
  final refreshListenable = GoRouterRefreshStream(
    ref.watch(authProvider.notifier).stream,
  );

  return GoRouter(
    initialLocation: '/map', // 앱의 첫 시작 화면은 항상 '/map'
    refreshListenable: refreshListenable,

    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authProvider);
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      final isUnauthenticated = authState.maybeWhen(
        unauthenticated: (_) => true, // unauthenticated 상태일 때만 true
        orElse: () => false, // 그 외 모든 경우는 false
      );

      final isAuthenticated = authState.maybeWhen(
        authenticated: () => true, // authenticated 상태일 때만 true
        orElse: () => false, // 그 외 모든 경우는 false
      );

      if (isUnauthenticated) {
        if (state.matchedLocation == '/write') {
          return '/login';
        }
      }

      if (isAuthenticated && isAuthRoute) {
        return '/map';
      }

      return null;
    },

    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/write',
        pageBuilder: (context, state) => _buildSlideTransitionPage(
          context: context,
          state: state,
          child: const WriteGrainScreen(),
        ),
      ),
      GoRoute(
        path: '/cloud/:cloudId',
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
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/map', builder: (context, state) => const MapScreen()),
          GoRoute(
            path: '/feed',
            builder: (context, state) => const FeedScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'privacy-policy',
                builder: (context, state) => const SimpleInfoScreen(
                  title: '개인정보처리방침',
                  body: privacyPolicyMarkdown,
                ),
              ),
              GoRoute(
                path: 'terms-of-service',
                builder: (context, state) => const SimpleInfoScreen(
                  title: '이용약관',
                  body: termsOfServiceMarkdown,
                ),
              ),
              GoRoute(
                path: 'contact',
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
});

// 화면 전환 애니메이션을 위한 재사용 함수 (수정 없음)
CustomTransitionPage<T> _buildSlideTransitionPage<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final isPopping = animation.status == AnimationStatus.reverse;
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
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

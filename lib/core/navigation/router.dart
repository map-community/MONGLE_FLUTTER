import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
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
import 'package:mongle_flutter/features/community/providers/issue_grain_providers.dart';
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
      debugPrint("🔐 Router redirect 호출됨");
      debugPrint("🔐 현재 경로: ${state.matchedLocation}");

      final authState = ref.read(authProvider);
      debugPrint("🔐 Auth 상태: $authState");

      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      final isUnauthenticated = authState.maybeWhen(
        unauthenticated: (_) => true, // unauthenticated 상태일 때만 true
        orElse: () => false, // 그 외 모든 경우는 false
      );

      final isAuthenticated = authState.maybeWhen(
        authenticated: (user) => true, // authenticated 상태일 때만 true
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
        pageBuilder: (context, state) {
          // extra로 전달된 데이터를 확인하고 타입 캐스팅합니다.
          final location = state.extra as NLatLng?;

          return _buildSlideTransitionPage(
            context: context,
            state: state,
            // WriteGrainScreen 생성자에 location을 전달합니다.
            child: WriteGrainScreen(location: location),
          );
        },
      ),
      GoRoute(
        path: '/cloud/:cloudId',
        pageBuilder: (context, state) {
          final cloudId = state.pathParameters['cloudId']!;
          final cloudName = state.extra as String?;

          return _buildSlideTransitionPage(
            context: context,
            state: state,
            child: CloudScreen(cloudId: cloudId, name: cloudName),
          );
        },
        routes: [
          GoRoute(
            path: 'grain/:grainId',
            pageBuilder: (context, state) {
              final grainId = state.pathParameters['grainId']!;

              // ✅ extra를 Map으로 파싱
              final extraData = state.extra as Map<String, dynamic>?;
              final boardName = extraData?['boardName'] as String?;
              final cloudProviderParam =
                  extraData?['cloudProviderParam'] as CloudProviderParam?;

              debugPrint("🔄 Router pageBuilder 호출됨");
              debugPrint("🔄 grainId: $grainId");
              debugPrint("🔄 boardName: $boardName");
              debugPrint("🔄 cloudProviderParam: $cloudProviderParam");

              return _buildSlideTransitionPage(
                context: context,
                state: state,
                child: GrainDetailScreen(
                  grainId: grainId,
                  boardName: boardName,
                  cloudProviderParam: cloudProviderParam, // ✅ 추가
                ),
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

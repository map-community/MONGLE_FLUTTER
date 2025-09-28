import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 1. 탭의 '동작'을 나타내는 함수(onTap)를 포함하도록 데이터 클래스를 확장합니다.
class _NavigationTab {
  final String routePath; // 현재 경로와 비교하기 위한 경로
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final void Function(BuildContext context, WidgetRef ref)
  onTap; // 탭을 눌렀을 때 실행될 '동작'

  const _NavigationTab({
    required this.routePath,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
  });
}

// 2. MainShell을 StatelessWidget에서 ConsumerWidget으로 변경합니다.
//    이는 onTap 함수 내부에서 ref를 사용하여 Provider를 읽을 수 있도록 하기 위함입니다.
class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  // 3. 탭 목록을 정의할 때, 각 탭이 눌렸을 때 수행할 '동작'까지 함께 정의합니다.
  static final _tabs = [
    _NavigationTab(
      routePath: '/map',
      icon: Icons.map_outlined,
      activeIcon: Icons.map,
      label: '지도',
      onTap: (context, ref) => context.go('/map'), // 단순 페이지 이동
    ),
    _NavigationTab(
      routePath: '/profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: '내 정보',
      // '내 정보' 탭은 더 복잡한 동작을 가집니다.
      onTap: (context, ref) {
        // --- ▼▼▼ 로그인 기능 추가 시 이 부분만 수정하면 됩니다 ▼▼▼ ---

        // final currentUser = ref.read(authProvider); // 예시: 나중에 authProvider를 읽어옴
        final currentUser = null; // 현재는 로그인 기능이 없으므로 null로 가정

        if (currentUser != null) {
          // context.go('/profile/${currentUser.id}');
        } else {
          // 로그인하지 않았을 때의 동작 (예: 로그인 안내 스낵바 표시)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('로그인이 필요한 기능입니다. (나중에 구현될 예정)'),
              duration: Duration(seconds: 1),
            ),
          );
        }
        // --- ▲▲▲ 여기까지 ---
      },
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // build 메소드에 ref 추가
    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabs.indexWhere(
          (tab) => GoRouterState.of(
            context,
          ).uri.toString().startsWith(tab.routePath),
        ),

        // 4. onTap 콜백은 이제 탭에 정의된 동작을 실행하기만 합니다.
        //    MainShell은 각 탭이 무슨 일을 하는지 더 이상 알 필요가 없습니다.
        onTap: (index) => _tabs[index].onTap(context, ref),

        items: _tabs
            .map(
              (tab) => BottomNavigationBarItem(
                icon: Icon(tab.icon),
                activeIcon: Icon(tab.activeIcon),
                label: tab.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:mongle_flutter/features/auth/presentation/providers/auth_state.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('내 정보')),
      body: ListView(
        children: [
          authState.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            authenticated: () {
              // 로그인된 상태일 때 보여줄 위젯
              return ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('로그아웃'),
                subtitle: const Text('다음에 또 만나요!'), // TODO: 실제 사용자 닉네임 표시
                onTap: () {
                  ref.read(authProvider.notifier).logout();
                },
              );
            },
            unauthenticated: (message) {
              // 로그아웃된 상태일 때 보여줄 위젯
              return ListTile(
                leading: const Icon(Icons.login),
                title: const Text('로그인 / 회원가입'),
                subtitle: const Text('로그인하고 몽글의 모든 기능을 사용해보세요!'),
                onTap: () {
                  context.go('/login');
                },
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text('개인정보처리방침'),
            onTap: () {
              // ✅ GoRouter를 사용하여 해당 경로로 이동
              context.go('/profile/privacy-policy');
            },
          ),

          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('이용약관'),
            onTap: () {
              context.go('/profile/terms-of-service');
            },
          ),

          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('문의하기'),
            onTap: () {
              context.go('/profile/contact');
            },
          ),
        ],
      ),
    );
  }
}

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
              // ✅ [수정] 로그인 된 상태의 메뉴 목록을 Column으로 묶습니다.
              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('로그아웃'),
                    subtitle: const Text('다음에 또 만나요!'), // TODO: 실제 사용자 닉네임 표시
                    onTap: () {
                      ref.read(authProvider.notifier).logout();
                    },
                  ),
                  // ✅ [추가] 회원 탈퇴 메뉴
                  ListTile(
                    leading: Icon(
                      Icons.person_remove_outlined,
                      color: Colors.grey[600],
                    ),
                    title: Text(
                      '회원탈퇴',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    onTap: () {
                      _showWithdrawConfirmationDialog(context, ref);
                    },
                  ),
                ],
              );
            },
            unauthenticated: (message) {
              // 로그아웃된 상태일 때 보여줄 위젯
              return ListTile(
                leading: const Icon(Icons.login),
                title: const Text('로그인 / 회원가입'),
                subtitle: const Text('로그인하고 몽글의 모든 기능을 사용해보세요!'),
                onTap: () {
                  context.push('/login');
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

  // ✅ [추가] 회원 탈퇴 확인 다이얼로그를 표시하는 메서드
  void _showWithdrawConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('회원 탈퇴'),
          content: const Text('정말로 탈퇴하시겠습니까?\n모든 데이터는 복구할 수 없습니다.'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('탈퇴', style: TextStyle(color: Colors.red)),
              // ✅ [수정] 스낵바를 띄우기 위해 async-await 적용
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // 다이얼로그 닫기

                // `withdraw()` 메서드는 이제 성공 시 null, 실패 시 에러 메시지(String)를 반환합니다.
                final String? errorMessage = await ref
                    .read(authProvider.notifier)
                    .withdraw();

                // 위젯이 아직 화면에 마운트되어 있는지 확인합니다.
                if (!context.mounted) return;

                if (errorMessage != null) {
                  // 실패한 경우: 에러 메시지를 담은 스낵바를 표시합니다.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                // 성공한 경우(errorMessage == null)에는 logout()이 호출되어 자동으로 화면이 전환되므로
                // 별도의 성공 스낵바는 표시하지 않아도 괜찮습니다.
              },
            ),
          ],
        );
      },
    );
  }
}

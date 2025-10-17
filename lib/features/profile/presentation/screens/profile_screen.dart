import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/common/widgets/user_profile_line.dart';
import 'package:mongle_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:mongle_flutter/features/auth/providers/user_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('내 정보')),
      body: ListView(
        children: [
          if (user != null)
            // 로그인 상태일 때 사용자 정보 표시
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Row(
                children: [
                  UserProfileLine(
                    profileImageUrl: user.profileImageUrl,
                    profileRadius: 32,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.nickname,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            // 비로그인 상태일 때 로그인/회원가입 버튼 표시
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('로그인 / 회원가입'),
              subtitle: const Text('로그인하고 몽글의 모든 기능을 사용해보세요!'),
              onTap: () {
                context.push('/login');
              },
            ),

          // ✅ [수정] 로그인 상태일 때만 로그아웃 메뉴를 표시합니다.
          if (user != null)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('로그아웃'),
              onTap: () {
                ref.read(authProvider.notifier).logout();
              },
            ),

          // ✅ [수정] 구분선을 여기에 하나만 둡니다.
          const Divider(),

          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text('개인정보처리방침'),
            onTap: () {
              _showTermsDialog(
                context,
                '개인정보처리방침',
                'https://sites.google.com/view/mongle-privacy-notice',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('이용약관'),
            onTap: () {
              _showTermsDialog(
                context,
                '이용약관',
                'https://sites.google.com/view/mongle-terms-of-service',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('문의하기'),
            onTap: () {
              context.go('/profile/contact');
            },
          ),

          // ✅ [수정] 로그인 상태일 때만 회원탈퇴 메뉴를 맨 아래에 표시합니다.
          if (user != null)
            ListTile(
              leading: Icon(
                Icons.person_remove_outlined,
                color: Colors.grey[600],
              ),
              title: Text('회원탈퇴', style: TextStyle(color: Colors.grey[600])),
              onTap: () {
                _showWithdrawConfirmationDialog(context, ref);
              },
            ),
        ],
      ),
    );
  }

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
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final String? errorMessage = await ref
                    .read(authProvider.notifier)
                    .withdraw();
                if (!context.mounted) return;
                if (errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showTermsDialog(BuildContext context, String title, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: WebViewWidget(
                  controller: WebViewController()
                    ..setJavaScriptMode(JavaScriptMode.unrestricted)
                    ..loadRequest(Uri.parse(url)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내 정보')),
      body: ListView(
        children: [
          // TODO: 여기에 프로필 정보 위젯 추가 (닉네임, 프로필 사진 등)
          const ListTile(
            leading: Icon(Icons.person),
            title: Text('계정 정보'),
            subtitle: Text('로그인 / 회원가입'),
            onTap: null, // TODO: 로그인 기능 연결
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

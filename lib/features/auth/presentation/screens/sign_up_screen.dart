// lib/features/auth/presentation/screens/sign_up_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mongle_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:mongle_flutter/features/auth/presentation/providers/auth_state.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(authProvider.notifier)
          .signUp(
            _emailController.text,
            _passwordController.text,
            _nicknameController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    final isLoading = authState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    ref.listen<AuthState>(authProvider, (previous, next) {
      next.whenOrNull(
        authenticated: () {
          context.go('/map'); // 회원가입 -> 자동 로그인 성공 시 홈으로
        },
        unauthenticated: (message) {
          if (message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.red),
            );
          }
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            // 내용이 길어질 수 있으므로 ListView 사용
            children: [
              const SizedBox(height: 40),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: '이메일'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    (value == null || value.isEmpty) ? '이메일을 입력해주세요.' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: '비밀번호'),
                obscureText: true,
                validator: (value) =>
                    (value == null || value.isEmpty) ? '비밀번호를 입력해주세요.' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(labelText: '닉네임'),
                validator: (value) =>
                    (value == null || value.isEmpty) ? '닉네임을 입력해주세요.' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('가입하고 시작하기'),
              ),
              TextButton(
                onPressed: () {
                  context.pop(); // 뒤로가기
                },
                child: const Text('이미 계정이 있나요? 로그인'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// lib/features/auth/presentation/screens/sign_up_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mongle_flutter/core/services/profanity_filter_service.dart'; // 비속어 필터 import
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
  final _passwordConfirmController = TextEditingController(); // 비밀번호 확인 컨트롤러
  final _nicknameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _submit() {
    // validate()가 true를 반환하면 (모든 validator가 null을 반환) API 요청 실행
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
          context.go('/map');
        },
        unauthenticated: (message) {
          if (message != null && context.mounted) {
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
            children: [
              const SizedBox(height: 20),
              // --- 이메일 필드 ---
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: '이메일'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력해주세요.';
                  }
                  // 이메일 형식 검사를 위한 정규표현식
                  final emailRegExp = RegExp(
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                  );
                  if (!emailRegExp.hasMatch(value)) {
                    return '올바른 이메일 형식이 아닙니다.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // --- 비밀번호 필드 ---
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: '비밀번호'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해주세요.';
                  }
                  if (value.length < 8) {
                    return '8자 이상으로 입력해주세요.';
                  }
                  if (value.length > 64) {
                    return '64자 이하로 입력해주세요.';
                  }
                  final numberRegExp = RegExp(r'[0-9]');
                  if (!numberRegExp.hasMatch(value)) {
                    return '숫자를 1개 이상 포함해주세요.';
                  }
                  // 특수문자 포함 여부 검사를 위한 정규표현식
                  final specialCharRegExp = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
                  if (!specialCharRegExp.hasMatch(value)) {
                    return '특수문자를 1개 이상 포함해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // --- 비밀번호 확인 필드 ---
              TextFormField(
                controller: _passwordConfirmController,
                decoration: const InputDecoration(labelText: '비밀번호 확인'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 다시 한번 입력해주세요.';
                  }
                  if (value != _passwordController.text) {
                    return '비밀번호가 일치하지 않습니다.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // --- 닉네임 필드 ---
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(labelText: '닉네임'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '닉네임을 입력해주세요.';
                  }
                  if (value.length < 2 || value.length > 10) {
                    return '2자 이상 10자 이하로 입력해주세요.';
                  }
                  // 자음/모음만 있는지 확인하는 정규표현식
                  final koreanConsonantVowelRegExp = RegExp(r'^[ㄱ-ㅎㅏ-ㅣ]+$');
                  if (koreanConsonantVowelRegExp.hasMatch(value)) {
                    return '자음 또는 모음만으로 닉네임을 만들 수 없습니다.';
                  }
                  // 특수문자, 공백 있는지 확인하는 정규표현식
                  final specialCharRegExp = RegExp(r'[!@#$%^&*(),.?":{}|<>\s]');
                  if (specialCharRegExp.hasMatch(value)) {
                    return '닉네임에는 특수문자나 공백을 사용할 수 없습니다.';
                  }
                  // 비속어 필터링
                  final profanityFilter = ref.read(profanityFilterProvider);
                  if (profanityFilter.containsProfanity(value)) {
                    return '사용할 수 없는 단어가 포함되어 있습니다.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('가입하고 시작하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

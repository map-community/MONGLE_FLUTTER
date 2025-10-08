// lib/features/auth/presentation/screens/sign_up_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mongle_flutter/core/services/profanity_filter_service.dart';
import 'package:mongle_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:mongle_flutter/features/auth/presentation/providers/auth_state.dart';
import 'package:mongle_flutter/features/auth/presentation/providers/sign_up_notifier.dart';
import 'package:mongle_flutter/features/auth/presentation/providers/sign_up_state.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // 1단계: 이메일
  final _emailController = TextEditingController();

  // 2단계: 인증 코드
  final _verificationCodeController = TextEditingController();
  Timer? _expiryTimer;
  int _remainingSeconds = 300; // 5분

  // 3단계: 비밀번호
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  // 4단계: 닉네임
  final _nicknameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _verificationCodeController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _nicknameController.dispose();
    _expiryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signUpState = ref.watch(signUpProvider);

    // 로그인 성공 시 /map으로 이동
    ref.listen<AuthState>(authProvider, (previous, next) {
      next.whenOrNull(
        authenticated: () {
          if (mounted) context.go('/map');
        },
      );
    });

    // 에러 메시지 표시
    ref.listen<SignUpState>(signUpProvider, (previous, next) {
      if (next.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(signUpState.step)),
        leading: _buildBackButton(signUpState.step),
      ),
      body: SafeArea(
        // 👈 이 한 줄 추가!
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildProgressIndicator(signUpState.step),
              const SizedBox(height: 24),
              Expanded(child: _buildStepContent(signUpState)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(SignUpStep step) {
    final currentStep = _getStepNumber(step);
    const totalSteps = 4;

    return Row(
      children: List.generate(totalSteps, (index) {
        final stepNum = index + 1;
        final isActive = stepNum <= currentStep;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.blue : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (index < totalSteps - 1) const SizedBox(width: 4),
            ],
          ),
        );
      }),
    );
  }

  int _getStepNumber(SignUpStep step) {
    switch (step) {
      case SignUpStep.emailInput:
        return 1;
      case SignUpStep.verificationSent:
        return 2;
      case SignUpStep.passwordInput:
        return 3;
      case SignUpStep.nicknameInput:
        return 4;
      case SignUpStep.completed:
        return 4;
    }
  }

  String _getAppBarTitle(SignUpStep step) {
    switch (step) {
      case SignUpStep.emailInput:
        return '회원가입 (1/4)';
      case SignUpStep.verificationSent:
        return '회원가입 (2/4)';
      case SignUpStep.passwordInput:
        return '회원가입 (3/4)';
      case SignUpStep.nicknameInput:
        return '회원가입 (4/4)';
      case SignUpStep.completed:
        return '가입 완료';
    }
  }

  Widget? _buildBackButton(SignUpStep step) {
    if (step == SignUpStep.emailInput) return null;

    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        ref.read(signUpProvider.notifier).goToPreviousStep();
      },
    );
  }

  Widget _buildStepContent(SignUpState signUpState) {
    switch (signUpState.step) {
      case SignUpStep.emailInput:
        return _buildEmailStep(signUpState);
      case SignUpStep.verificationSent:
        return _buildVerificationStep(signUpState);
      case SignUpStep.passwordInput:
        return _buildPasswordStep(signUpState);
      case SignUpStep.nicknameInput:
        return _buildNicknameStep(signUpState);
      case SignUpStep.completed:
        return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _buildEmailStep(SignUpState signUpState) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '이메일 인증',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '가입하실 이메일 주소를 입력해주세요.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: '이메일',
              hintText: 'user@example.com',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '이메일을 입력해주세요.';
              }
              final emailRegExp = RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
              );
              if (!emailRegExp.hasMatch(value)) {
                return '올바른 이메일 형식이 아닙니다.';
              }
              return null;
            },
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: signUpState.isLoading ? null : _sendVerificationCode,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: signUpState.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('다음', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStep(SignUpState signUpState) {
    _startExpiryTimer();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '인증 코드 확인',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '${signUpState.email ?? ""}로 발송된\n인증 코드를 입력해주세요.',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 32),
        TextFormField(
          controller: _verificationCodeController,
          decoration: InputDecoration(
            labelText: '인증 코드',
            hintText: '6자리 숫자',
            border: const OutlineInputBorder(),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                widthFactor: 1.0,
                child: Text(
                  _formatTime(_remainingSeconds),
                  style: TextStyle(
                    color: _remainingSeconds < 60 ? Colors.red : Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: signUpState.isLoading ? null : _resendVerificationCode,
          child: const Text('인증 코드 재발송'),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: signUpState.isLoading ? null : _verifyCode,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: signUpState.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('다음', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildPasswordStep(SignUpState signUpState) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '비밀번호 설정',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '안전한 비밀번호를 설정해주세요.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: '비밀번호',
              hintText: '8자 이상, 숫자와 특수문자 포함',
              border: OutlineInputBorder(),
            ),
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
              final specialCharRegExp = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
              if (!specialCharRegExp.hasMatch(value)) {
                return '특수문자를 1개 이상 포함해주세요.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordConfirmController,
            decoration: const InputDecoration(
              labelText: '비밀번호 확인',
              border: OutlineInputBorder(),
            ),
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
          const Spacer(),
          ElevatedButton(
            onPressed: _submitPassword,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('다음', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildNicknameStep(SignUpState signUpState) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '닉네임 설정',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '서비스에서 사용할 닉네임을 입력해주세요.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _nicknameController,
            decoration: const InputDecoration(
              labelText: '닉네임',
              hintText: '2-10자',
              border: OutlineInputBorder(),
              helperText: '특수문자, 공백 사용 불가',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '닉네임을 입력해주세요.';
              }
              if (value.length < 2 || value.length > 10) {
                return '2자 이상 10자 이하로 입력해주세요.';
              }
              final koreanConsonantVowelRegExp = RegExp(r'^[ㄱ-ㅎㅏ-ㅣ]+$');
              if (koreanConsonantVowelRegExp.hasMatch(value)) {
                return '자음 또는 모음만으로 닉네임을 만들 수 없습니다.';
              }
              final specialCharRegExp = RegExp(r'[!@#$%^&*(),.?":{}|<>\s]');
              if (specialCharRegExp.hasMatch(value)) {
                return '닉네임에는 특수문자나 공백을 사용할 수 없습니다.';
              }
              final profanityFilter = ref.read(profanityFilterProvider);
              if (profanityFilter.containsProfanity(value)) {
                return '사용할 수 없는 단어가 포함되어 있습니다.';
              }
              return null;
            },
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: signUpState.isLoading ? null : _submitSignUp,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: signUpState.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('가입하고 시작하기', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  // ===== 액션 메서드들 =====

  void _sendVerificationCode() async {
    if (_formKey.currentState!.validate()) {
      final error = await ref
          .read(signUpProvider.notifier)
          .requestVerificationCode(_emailController.text);

      if (error == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('인증 코드가 발송되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _resendVerificationCode() async {
    final error = await ref
        .read(signUpProvider.notifier)
        .requestVerificationCode(_emailController.text);

    if (error == null && mounted) {
      _remainingSeconds = 300;
      _verificationCodeController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('인증 코드가 재발송되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _verifyCode() async {
    if (_verificationCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('인증 코드를 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final error = await ref
        .read(signUpProvider.notifier)
        .verifyCode(_verificationCodeController.text);

    if (error == null && mounted) {
      _expiryTimer?.cancel();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이메일 인증이 완료되었습니다!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _submitPassword() {
    if (_formKey.currentState!.validate()) {
      ref.read(signUpProvider.notifier).savePassword(_passwordController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('비밀번호가 설정되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _submitSignUp() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref
          .read(signUpProvider.notifier)
          .signUp(_nicknameController.text);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('회원가입이 완료되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _startExpiryTimer() {
    _expiryTimer?.cancel();
    _remainingSeconds = 300; // 5분

    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          timer.cancel();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('인증 코드가 만료되었습니다. 다시 요청해주세요.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

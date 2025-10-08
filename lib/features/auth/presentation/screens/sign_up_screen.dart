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
import 'package:webview_flutter/webview_flutter.dart';

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
  Timer? _resendCooldownTimer;
  int _resendCooldownSeconds = 0;
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
    _resendCooldownTimer?.cancel();
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

    // 에러 메시지 표시 및 타이머 관리
    ref.listen<SignUpState>(signUpProvider, (previous, next) {
      if (next.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }

      // 追加: 타이머 시작/중지 로직
      final prevStep = previous?.step;
      // verificationSent 단계로 처음 진입했을 때 타이머 시작
      if (next.step == SignUpStep.verificationSent &&
          prevStep != SignUpStep.verificationSent) {
        _startExpiryTimer();
      }
      // verificationSent 단계를 벗어나면 타이머 취소
      else if (next.step != SignUpStep.verificationSent &&
          prevStep == SignUpStep.verificationSent) {
        _expiryTimer?.cancel();
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
    const totalSteps = 5;

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
      case SignUpStep.termsAgreement: // 🆕
        return 5;
      case SignUpStep.completed:
        return 5;
    }
  }

  String _getAppBarTitle(SignUpStep step) {
    switch (step) {
      case SignUpStep.emailInput:
        return '회원가입 (1/5)';
      case SignUpStep.verificationSent:
        return '회원가입 (2/5)';
      case SignUpStep.passwordInput:
        return '회원가입 (3/5)';
      case SignUpStep.nicknameInput:
        return '회원가입 (4/5)';
      case SignUpStep.termsAgreement: // 🆕
        return '회원가입 (5/5)';
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
      case SignUpStep.termsAgreement: // 🆕
        return _buildTermsAgreementStep(signUpState);
      case SignUpStep.completed:
        return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _buildEmailStep(SignUpState signUpState) {
    // 👇 [추가] 재발송 버튼과 동일한 비활성화 로직
    final isResendDisabled = _resendCooldownSeconds > 0;

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
            // 👇 [수정] 쿨다운 중일 때 버튼 비활성화
            onPressed: signUpState.isLoading || isResendDisabled
                ? null
                : _sendVerificationCode,
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
                // 👇 [수정] 쿨다운 중일 때 남은 시간 표시
                : Text(
                    isResendDisabled
                        ? '인증 코드 보내기 (${_resendCooldownSeconds}초)'
                        : '인증 코드 보내기',
                    style: const TextStyle(fontSize: 16),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStep(SignUpState signUpState) {
    final isResendDisabled = _resendCooldownSeconds > 0;

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
          // 👇 [수정] isResendDisabled 상태에 따라 onPressed 비활성화
          onPressed: signUpState.isLoading || isResendDisabled
              ? null
              : _resendVerificationCode,
          // 👇 [수정] isResendDisabled 상태에 따라 버튼 텍스트 변경
          child: Text(
            isResendDisabled
                ? '인증 코드 재발송 (${_resendCooldownSeconds}초)'
                : '인증 코드 재발송',
          ),
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
              : const Text('이메일 인증 완료', style: TextStyle(fontSize: 16)),
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
            onPressed: signUpState.isLoading ? null : _submitNickname, // 🔹 변경
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: signUpState.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    '다음',
                    style: TextStyle(fontSize: 16),
                  ), // 🔹 "가입하고 시작하기" → "다음"
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAgreementStep(SignUpState signUpState) {
    final allAgreed = signUpState.termsAgreed && signUpState.privacyAgreed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '약관 동의',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          '서비스 이용을 위해 약관에 동의해주세요.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 24),

        // 전체 동의
        CheckboxListTile(
          title: const Text(
            '전체 동의',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          value: allAgreed,
          onChanged: (value) {
            ref
                .read(signUpProvider.notifier)
                .toggleAllAgreements(value ?? false);
          },
          controlAffinity: ListTileControlAffinity.leading,
        ),

        const Divider(),

        // 서비스 이용약관
        CheckboxListTile(
          title: const Text('서비스 이용약관 (필수)'),
          subtitle: GestureDetector(
            onTap: () => _showTermsDialog(
              context,
              '서비스 이용약관',
              'https://sites.google.com/view/mongle-terms-of-service',
            ),
            child: const Text(
              '내용 보기',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          value: signUpState.termsAgreed,
          onChanged: (value) {
            ref
                .read(signUpProvider.notifier)
                .toggleTermsAgreement(value ?? false);
          },
          controlAffinity: ListTileControlAffinity.leading,
        ),

        // 개인정보 처리방침
        CheckboxListTile(
          title: const Text('개인정보 처리방침 (필수)'),
          subtitle: GestureDetector(
            onTap: () => _showTermsDialog(
              context,
              '개인정보 처리방침',
              'https://sites.google.com/view/mongle-privacy-notice',
            ),
            child: const Text(
              '내용 보기',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          value: signUpState.privacyAgreed,
          onChanged: (value) {
            ref
                .read(signUpProvider.notifier)
                .togglePrivacyAgreement(value ?? false);
          },
          controlAffinity: ListTileControlAffinity.leading,
        ),

        const Spacer(),

        ElevatedButton(
          onPressed:
              (signUpState.termsAgreed &&
                  signUpState.privacyAgreed &&
                  !signUpState.isLoading)
              ? _submitFinalSignUp
              : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: signUpState.isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('가입하고 시작하기', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  void _showTermsDialog(BuildContext context, String title, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        // 👇 [수정 1] Dialog 자체의 외부 여백을 제거합니다.
        insetPadding: EdgeInsets.zero,
        child: Container(
          width: double.infinity,
          // 👇 [수정 2] 높이를 화면 끝까지 최대로 설정합니다.
          height: double.infinity,
          // 내부 콘텐츠 여백은 그대로 유지합니다.
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

  // ===== 액션 메서드들 =====

  void _submitFinalSignUp() async {
    final success = await ref
        .read(signUpProvider.notifier)
        .signUp(); // 🔹 파라미터 없음!

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('회원가입이 완료되었습니다!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _sendVerificationCode() async {
    if (_formKey.currentState!.validate()) {
      final error = await ref
          .read(signUpProvider.notifier)
          .requestVerificationCode(_emailController.text);

      if (error == null && mounted) {
        _startResendCooldown();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('인증 코드가 발송되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
      // 👇 [추가] 쿨다운 등 에러 발생 시 피드백
      else if (error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.orange),
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
      _startExpiryTimer(); // 타이머를 새로 시작합니다.
      _startResendCooldown(); // 👇 [추가] 재발송 쿨다운 시작

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('인증 코드가 재발송되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (error != null && mounted) {
      // 60초 쿨다운 에러 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.orange),
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

  void _submitNickname() {
    // 🔹 이름 변경
    if (_formKey.currentState!.validate()) {
      ref
          .read(signUpProvider.notifier)
          .saveNickname(_nicknameController.text); // 🔹 변경

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('닉네임이 설정되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _startExpiryTimer() {
    // 修正: 기존 타이머가 있으면 확실히 취소
    _expiryTimer?.cancel();

    // 修正: 초를 리셋하고 즉시 UI에 반영
    setState(() {
      _remainingSeconds = 1800; // 30분
    });

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
          if (mounted) {
            // 修正: mounted 체크 추가
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('인증 코드가 만료되었습니다. 다시 요청해주세요.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      });
    });
  }

  // 재발송 쿨다운 타이머 시작 함수
  void _startResendCooldown() {
    _resendCooldownTimer?.cancel();
    setState(() {
      _resendCooldownSeconds = 30;
    });

    _resendCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_resendCooldownSeconds > 0) {
          _resendCooldownSeconds--;
        } else {
          timer.cancel();
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

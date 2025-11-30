// lib/features/auth/presentation/signup_screen.dart

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/widgets/app_page_scaffold.dart';
import '../../../core/widgets/app_auth_header.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/portrait_lock.dart';
import '../providers/signup_controller.dart';
import '../signup/widgets/signup_form_section.dart';

class SignupScreen extends HookConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signupAsync = ref.watch(signupControllerProvider);
    final state = signupAsync.value ?? SignupState.initial();
    final signupCtrl = ref.read(signupControllerProvider.notifier);

    final idController = useTextEditingController();
    final nameController = useTextEditingController();
    final ageController = useTextEditingController();
    final phoneController = useTextEditingController();
    final emailController = useTextEditingController();
    final pwController = useTextEditingController();
    final pwConfirmController = useTextEditingController();

    Future<void> onSignUpPressed() async {
      final username = idController.text.trim();
      final name = nameController.text.trim();
      final ageText = ageController.text.trim();
      final phone = phoneController.text.trim();
      final email = emailController.text.trim();
      final pw = pwController.text.trim();
      final pwConfirm = pwConfirmController.text.trim();

      if (username.isEmpty ||
          name.isEmpty ||
          ageText.isEmpty ||
          phone.isEmpty ||
          email.isEmpty ||
          pw.isEmpty ||
          pwConfirm.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('모든 항목을 입력해 주세요.')),
        );
        return;
      }

      final age = int.tryParse(ageText);
      if (age == null || age <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('유효한 나이를 입력해 주세요.')),
        );
        return;
      }

      final phoneReg = RegExp(r'^[0-9]+$');
      if (!phoneReg.hasMatch(phone)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('전화번호는 숫자만 입력해 주세요.')),
        );
        return;
      }

      if (!EmailValidator.validate(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('유효한 이메일을 입력해 주세요.')),
        );
        return;
      }

      if (pw.length < 8) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('비밀번호는 8자 이상이어야 합니다.')),
        );
        return;
      }

      if (pw != pwConfirm) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
        );
        return;
      }

      final ok = await signupCtrl.signUp(
        username: username, 
        name: name,
        age: age,
        phoneNumber: phone,
        email: email,
        password: pw,
      );

      if (!context.mounted) return;

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입이 완료되었습니다. 로그인해 주세요.')),
        );
        context.go('/login');
      } else {
        final msg = signupAsync.value?.errorMessage;
        if (msg != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          );
        }
      }
    }

    final isLoading = state.isLoading;

    return PortraitLock(
      child: AppPageScaffold(
        header: const AppAuthHeader(
          title: '회원가입',
          subtitle: '기본 정보를 입력하고 강아지 텔레파시를 시작해볼까요?',
        ),
        children: [
          SizedBox(height: 12.h),
          SignupFormSection(
            idController: idController,
            nameController: nameController,
            ageController: ageController,
            phoneController: phoneController,
            emailController: emailController,
            pwController: pwController,
            pwConfirmController: pwConfirmController,
          ),
        ],
        bottom: Column(
          children: [
            AppButton(
              text: '회원가입',
              onPressed: isLoading ? () {} : onSignUpPressed,
              isLoading: isLoading,
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('이미 계정이 있나요? 로그인'),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/features/auth/presentation/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_page_scaffold.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/portrait_lock.dart';
import '../../../core/widgets/app_check_option.dart';
import '../login/widgets/login_form_section.dart';
import '../providers/auth_controller.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authControllerProvider);
    final authState = authAsync.value ?? AuthState.initial();
    final authCtrl = ref.read(authControllerProvider.notifier);

    final idController = useTextEditingController();
    final pwController = useTextEditingController();

    useEffect(() {
      if (authState.savedId != null && idController.text.isEmpty) {
        idController.text = authState.savedId!;
      }
      return null;
    }, [authState.savedId]);

    Future<void> onLogin() async {
      final id = idController.text.trim();
      final pw = pwController.text.trim();

      if (id.isEmpty || pw.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("아이디와 비밀번호를 입력하세요.")),
        );
        return;
      }

      final success = await authCtrl.signIn(
        username: id,
        password: pw,
      );

      if (!context.mounted) return;

      if (success) {
        context.go("/mode-select");
      } else {
        final errorMsg = authState.errorMessage ?? "로그인에 실패했습니다.";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    }

    return PortraitLock(
      child: AppPageScaffold(
        isCentered: true,
        header: Column(
          children: [
            Text(
              '견심술',
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8B6E57),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              '반려견의 마음을 읽어보세요',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 48.h),
          ],
        ),
        children: [
          LoginFormSection(
            idController: idController,
            pwController: pwController,
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppCheckOption(
                label: '아이디 저장',
                value: authState.saveId,
                onChanged: (_) => authCtrl.toggleSaveId(),
              ),
              AppCheckOption(
                label: '자동 로그인',
                value: authState.autoLogin,
                onChanged: (_) => authCtrl.toggleAutoLogin(),
              ),
            ],
          ),
        ],
        bottom: Column(
          children: [
            AppButton(
              text: "로그인",
              isLoading: authState.isLoading,
              onPressed: authState.isLoading ? () {} : onLogin,
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: () => context.go('/signup'),
              child: Text(
                '아직 계정이 없나요? 회원가입',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14.sp,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: () => context.go('/manager'),
              child: const Text('임시 관리자 화면 이동'),
            ),
          ],
        ),
      ),
    );
  }
}

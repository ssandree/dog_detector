// lib/features/auth/login/widgets/login_form_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_text_field.dart';

class LoginFormSection extends HookWidget {
  final TextEditingController idController;
  final TextEditingController pwController;

  const LoginFormSection({
    super.key,
    required this.idController,
    required this.pwController,
  });

  @override
  Widget build(BuildContext context) {
    final showPw = useState(false);

    return Column(
      children: [
        AppTextField(
          label: '아이디',
          hint: '아이디를 입력하세요',
          controller: idController,
        ),
        SizedBox(height: 20.h),
        AppTextField(
          label: '비밀번호',
          hint: '비밀번호를 입력하세요',
          controller: pwController,
          obscureText: !showPw.value,
          suffixIcon: IconButton(
            icon: Icon(
              showPw.value ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () => showPw.value = !showPw.value,
          ),
        ),
      ],
    );
  }
}

// lib/features/auth/signup/widgets/signup_form_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_form_section.dart';
import '../../../../core/widgets/app_text_field.dart';

class SignupFormSection extends StatelessWidget {
  final TextEditingController idController;
  final TextEditingController nameController;
  final TextEditingController ageController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController pwController;
  final TextEditingController pwConfirmController;

  const SignupFormSection({
    super.key,
    required this.idController,
    required this.nameController,
    required this.ageController,
    required this.phoneController,
    required this.emailController,
    required this.pwController,
    required this.pwConfirmController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppFormSection(
          label: '아이디',
          child: AppTextField(
            label: '',
            hint: '아이디 입력',
            controller: idController,
          ),
        ),
        SizedBox(height: 16.h),
        AppFormSection(
          label: '이름',
          child: AppTextField(
            label: '',
            hint: '이름 입력',
            controller: nameController,
          ),
        ),
        SizedBox(height: 16.h),
        AppFormSection(
          label: '나이',
          child: AppTextField(
            label: '',
            hint: '나이 입력',
            controller: ageController,
            keyboardType: TextInputType.number,
          ),
        ),
        SizedBox(height: 16.h),
        AppFormSection(
          label: '전화번호',
          child: AppTextField(
            label: '',
            hint: '휴대폰 번호 (숫자만 입력)',
            controller: phoneController,
            keyboardType: TextInputType.phone,
          ),
        ),
        SizedBox(height: 16.h),
        AppFormSection(
          label: '이메일',
          child: AppTextField(
            label: '',
            hint: '이메일 입력',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
          ),
        ),
        SizedBox(height: 16.h),
        AppFormSection(
          label: '비밀번호',
          child: AppTextField(
            label: '',
            hint: '영문, 숫자 포함 8자 이상',
            controller: pwController,
            obscureText: true,
          ),
        ),
        SizedBox(height: 16.h),
        AppFormSection(
          label: '비밀번호 확인',
          child: AppTextField(
            label: '',
            hint: '비밀번호 재입력',
            controller: pwConfirmController,
            obscureText: true,
          ),
        ),
      ],
    );
  }
}

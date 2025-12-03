// lib/manager/update_modal/me_update_modal.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/config/app_colors.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_toast.dart';

import '../logic/model/user_profile.dart';
import '../logic/provider/user_provider.dart';

Future<void> showMeUpdateModal(
  BuildContext context, {
  UserProfile? existingUserInfo,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (dialogContext) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        backgroundColor: Colors.transparent,
        child: MeUpdateModal(existingUserInfo: existingUserInfo),
      );
    },
  );
}

class MeUpdateModal extends ConsumerStatefulWidget {
  final UserProfile? existingUserInfo;

  const MeUpdateModal({super.key, this.existingUserInfo});

  @override
  ConsumerState<MeUpdateModal> createState() => _MeUpdateModalState();
}

class _MeUpdateModalState extends ConsumerState<MeUpdateModal> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _initialized = false;
  UserProfile? _initialUser;

  @override
  void initState() {
    super.initState();
    _initialUser = widget.existingUserInfo;

    if (_initialUser != null) {
      _loadFormData(_initialUser!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized && _initialUser == null) {
      final userAsync = ref.read(currentUserProvider);
      if (userAsync.hasValue && userAsync.value != null) {
        _initialUser = userAsync.value;
        _loadFormData(userAsync.value!);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadFormData(UserProfile user) {
    if (_initialized) return;

    _emailController.text = user.email;
    _nameController.text = user.name ?? "";
    _ageController.text = user.age?.toString() ?? "";
    _phoneController.text = user.phoneNumber ?? "";

    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _initialUser != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          )
        ],
      ),
      padding: EdgeInsets.all(AppConstants.largeSpacing),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _title(isEdit),
            SizedBox(height: AppConstants.largeSpacing),
            _emailField(),
            SizedBox(height: AppConstants.largeSpacing),
            _nameField(),
            SizedBox(height: AppConstants.largeSpacing),
            _ageField(),
            SizedBox(height: AppConstants.largeSpacing),
            _phoneField(),
            SizedBox(height: AppConstants.extraLargeSpacing),
            _submitButton(isEdit),
          ],
        ),
      ),
    );
  }

  Widget _title(bool isEdit) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '내 정보 수정',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        )
      ],
    );
  }

  Widget _emailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('이메일', style: TextStyle(fontSize: 14)),
        AppConstants.h12,
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: '이메일',
            hintText: '예: user@example.com',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return '이메일을 입력해주세요';
            }
            if (!v.contains('@')) {
              return '올바른 이메일 형식을 입력해주세요';
            }
            return null;
          },
        )
      ],
    );
  }

  Widget _nameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('이름', style: TextStyle(fontSize: 14)),
        AppConstants.h12,
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: '이름',
            hintText: '이름을 입력해주세요',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
        )
      ],
    );
  }

  Widget _ageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('나이', style: TextStyle(fontSize: 14)),
        AppConstants.h12,
        TextFormField(
          controller: _ageController,
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          decoration: const InputDecoration(
            labelText: '나이',
            hintText: '나이를 입력해주세요',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.cake),
            suffixText: "세",
          ),
          validator: (v) {
            if (v != null && v.trim().isNotEmpty) {
              final n = int.tryParse(v);
              if (n == null || n < 0 || n > 150) {
                return "0 ~ 150 사이로 입력해주세요";
              }
            }
            return null;
          },
        )
      ],
    );
  }

  Widget _phoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('전화번호', style: TextStyle(fontSize: 14)),
        AppConstants.h12,
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: '전화번호',
            hintText: '예: 010-1234-5678',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
        )
      ],
    );
  }

  Widget _submitButton(bool isEdit) {
    return AppButton(
      text: "정보 수정하기",
      backgroundColor: AppColors.beige4,
      height: 52,
      onPressed: _submit,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final name = _nameController.text.trim().isEmpty 
        ? null 
        : _nameController.text.trim();
    final age = _ageController.text.trim().isEmpty
        ? null
        : int.tryParse(_ageController.text.trim());
    final phoneNumber = _phoneController.text.trim().isEmpty
        ? null
        : _phoneController.text.trim();

    final updatedUser = _initialUser!.copyWith(
      email: email,
      name: name,
      age: age,
      phoneNumber: phoneNumber,
    );

    try {
      final service = ref.read(userServiceProvider);
      await service.updateCurrentUser(updatedUser);
      
      // Provider 새로고침
      ref.invalidate(currentUserProvider);
      
      if (mounted) {
        AppToast.success(context, "정보가 수정되었습니다!");
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, e);
    }
  }
}


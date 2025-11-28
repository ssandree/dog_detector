import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/app_constants.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/models/pet_info.dart';
import '../../../core/provider/current_pet_provider.dart';
import '../../../core/provider/pet_provider.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_toast.dart';

Future<void> showPetRegiModal(
  BuildContext context, {
  PetInfo? existingPetInfo,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (dialogContext) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        backgroundColor: Colors.transparent,
        child: PetRegiModal(
          existingPetInfo: existingPetInfo,
        ),
      );
    },
  );
}

class PetRegiModal extends ConsumerStatefulWidget {
  final PetInfo? existingPetInfo;

  const PetRegiModal({
    super.key,
    this.existingPetInfo,
  });

  @override
  ConsumerState<PetRegiModal> createState() => _PetRegiModalState();
}

class _PetRegiModalState extends ConsumerState<PetRegiModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();

  bool _isInitialized = false;
  DateTime? _selectedBirthday;
  PetInfo? _existingPetInfo;

  @override
  void initState() {
    super.initState();
    _existingPetInfo = widget.existingPetInfo;
    if (_existingPetInfo != null) {
      _initializeForm(_existingPetInfo!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized && _existingPetInfo == null) {
      final petInfo = ref.read(currentPetProvider);
      if (petInfo != null) {
        _existingPetInfo = petInfo;
        _initializeForm(petInfo);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _initializeForm(PetInfo petInfo) {
    if (_isInitialized) return;

    _nameController.text = petInfo.name;
    _weightController.text = petInfo.weightKg?.toString() ?? '';
    _selectedBirthday = petInfo.birthDate;
    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = _existingPetInfo != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.all(AppConstants.largeSpacing),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    isEditMode ? '강아지 정보 수정' : '강아지 등록',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            SizedBox(height: AppConstants.largeSpacing),
            _buildNameField(),
            SizedBox(height: AppConstants.largeSpacing),
            _buildBirthdayField(),
            SizedBox(height: AppConstants.largeSpacing),
            _buildWeightField(),
            SizedBox(height: AppConstants.extraLargeSpacing),
            AppButton.primary(
              text: isEditMode ? '정보 수정하기' : '강아지 등록하기',
              onPressed: _registerPet,
              backgroundColor: AppColors.beige4,
              height: 52,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '기본 정보',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        AppConstants.h16,
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: '강아지 이름',
            hintText: '강아지 이름을 입력해주세요',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.pets),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '강아지 이름을 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBirthdayField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '생일 정보',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        AppConstants.h16,
        InkWell(
          onTap: _selectBirthday,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.grey7),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedBirthday != null
                        ? '${_selectedBirthday!.year}.${_selectedBirthday!.month.toString().padLeft(2, '0')}.${_selectedBirthday!.day.toString().padLeft(2, '0')}'
                        : '생일을 선택해주세요',
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedBirthday != null
                          ? AppColors.black
                          : AppColors.grey7,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        if (_selectedBirthday != null) ...[
          AppConstants.h8,
          Text(
            '나이: ${_calculateAge(_selectedBirthday!)}살',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.grey8,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWeightField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '몸무게',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        AppConstants.h16,
        TextFormField(
          controller: _weightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: '몸무게',
            hintText: '몸무게를 입력해주세요',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.monitor_weight),
            suffixText: 'kg',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '몸무게를 입력해주세요';
            }
            final weight = double.tryParse(value);
            if (weight == null || weight <= 0 || weight > 100) {
              return '올바른 몸무게를 입력해주세요 (0.1-100kg)';
            }
            return null;
          },
        ),
      ],
    );
  }

  Future<void> _registerPet() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBirthday == null) {
      AppToast.error(context, '생일을 선택해주세요');
      return;
    }

    final name = _nameController.text.trim();
    final weight = double.parse(_weightController.text.trim());
    final birthday = _selectedBirthday!;
    final age = _calculateAge(birthday);

    final petInfo = PetInfo(
      petId: _existingPetInfo?.petId,
      userId: _existingPetInfo?.userId,
      name: name,
      breed: _existingPetInfo?.breed,
      birthDate: birthday,
      weightKg: weight,
      photoUrl: _existingPetInfo?.photoUrl,
      age: age,
      gender: _existingPetInfo?.gender,
    );

    try {
      final petNotifier = ref.read(petProvider.notifier);

      if (_existingPetInfo != null) {
        final petId = _existingPetInfo!.petId;
        if (petId == null) {
          AppToast.error(context, '반려동물 ID를 찾을 수 없습니다.');
          return;
        }

        await petNotifier.updatePetInfo(petId.toString(), petInfo);
        if (mounted) {
          AppToast.success(context, '$name의 정보가 성공적으로 수정되었습니다!');
          Navigator.of(context).pop();
        }
      } else {
        await petNotifier.createPetInfo(petInfo);
        if (mounted) {
          AppToast.success(context, '$name이(가) 성공적으로 등록되었습니다!');
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        final action = _existingPetInfo != null ? '수정' : '등록';
        final errorMessage = e.toString().contains('Exception:')
            ? e.toString().split('Exception:').last.trim()
            : '$action에 실패했습니다. 다시 시도해주세요.';
        AppToast.error(context, errorMessage);
      }
    }
  }

  int _calculateAge(DateTime birthday) {
    final now = DateTime.now();
    int age = now.year - birthday.year;
    if (now.month < birthday.month ||
        (now.month == birthday.month && now.day < birthday.day)) {
      age--;
    }
    return age;
  }

  Future<void> _selectBirthday() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate:
          _selectedBirthday ?? DateTime.now().subtract(const Duration(days: 365 * 2)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
      lastDate: DateTime.now(),
      helpText: '생일 선택',
    );

    if (selectedDate != null && mounted) {
      setState(() {
        _selectedBirthday = selectedDate;
      });
    }
  }
}


// lib/features/pet/presentation/pet_regi_modal.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/config/app_colors.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_toast.dart';

import '../../pet/domain/pet_info.dart';
import '../../pet/application/pet_provider.dart';
import '../../pet/application/current_pet_provider.dart';

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
        child: PetRegiModal(existingPetInfo: existingPetInfo),
      );
    },
  );
}

class PetRegiModal extends ConsumerStatefulWidget {
  final PetInfo? existingPetInfo;

  const PetRegiModal({super.key, this.existingPetInfo});

  @override
  ConsumerState<PetRegiModal> createState() => _PetRegiModalState();
}

class _PetRegiModalState extends ConsumerState<PetRegiModal> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  bool _initialized = false;
  DateTime? _birthday;
  PetInfo? _initialPet;

  @override
  void initState() {
    super.initState();
    _initialPet = widget.existingPetInfo;

    if (_initialPet != null) {
      _loadFormData(_initialPet!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized && _initialPet == null) {
      final saved = ref.read(currentPetProvider);
      if (saved != null) {
        _initialPet = saved;
        _loadFormData(saved);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _loadFormData(PetInfo info) {
    if (_initialized) return;

    _nameController.text = info.name;
    _breedController.text = info.breed ?? "";
    _weightController.text = info.weightKg?.toString() ?? "";
    _heightController.text = info.heightCm?.toString() ?? "";
    _birthday = info.birthDate;

    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _initialPet != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
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
            _nameField(),
            SizedBox(height: AppConstants.largeSpacing),
            _birthField(),
            SizedBox(height: AppConstants.largeSpacing),
            _bodyField(),
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
            isEdit ? '강아지 정보 수정' : '강아지 등록',
            style: const TextStyle(
              fontSize: 20,
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

  Widget _nameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('이름', style: TextStyle(fontSize: 16)),
        AppConstants.h16,
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: '강아지 이름',
            hintText: '예: 몽이',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.pets),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? '이름을 입력해주세요' : null,
        )
      ],
    );
  }

  Widget _birthField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('출생', style: TextStyle(fontSize: 16)),
        AppConstants.h16,
    TextFormField(
      controller: _breedController,
      decoration: const InputDecoration(
        labelText: '강아지 종',
        hintText: '예: 말티즈, 포메라니안 등',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category),
      ),
    ),
    const SizedBox(height: 16),
        InkWell(
          onTap: _pickBirth,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _birthday != null
                        ? "${_birthday!.year}.${_birthday!.month.toString().padLeft(2, '0')}.${_birthday!.day.toString().padLeft(2, '0')}"
                        : "생일을 선택해주세요",
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          _birthday != null ? AppColors.black : AppColors.grey7,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down)
              ],
            ),
          ),
        ),
        if (_birthday != null) ...[
          AppConstants.h8,
          Text(
            "나이: ${_calcAge(_birthday!)}살",
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.grey8,
            ),
          )
        ]
      ],
    );
  }

  Widget _bodyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("신체", style: TextStyle(fontSize: 16)),
        AppConstants.h16,
        TextFormField(
          controller: _weightController,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: '몸무게',
            hintText: '몸무게를 입력해주세요',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.monitor_weight),
            suffixText: "kg",
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return "몸무게를 입력해주세요";
            }
            final n = double.tryParse(v);
            if (n == null || n <= 0 || n > 100) {
              return "0.1 ~ 100kg 사이로 입력해주세요";
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _heightController,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: '키',
            hintText: '키를 입력해주세요',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.height),
            suffixText: "cm",
          ),
          validator: (v) {
            if (v != null && v.trim().isNotEmpty) {
              final n = double.tryParse(v);
              if (n == null || n <= 0 || n > 200) {
                return "0.1 ~ 200cm 사이로 입력해주세요";
              }
            }
            return null;
          },
        )
      ],
    );
  }

  Widget _submitButton(bool isEdit) {
    return AppButton(
      text: isEdit ? "정보 수정하기" : "강아지 등록하기",
      backgroundColor: AppColors.beige4,
      height: 52,
      onPressed: _submit,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_birthday == null) {
      AppToast.error(context, "생일을 선택해주세요");
      return;
    }

    final name = _nameController.text.trim();
    final breed =
        _breedController.text.trim().isEmpty ? null : _breedController.text.trim();
    final weight = double.parse(_weightController.text.trim());
    final height = _heightController.text.trim().isEmpty
        ? null
        : double.parse(_heightController.text.trim());
    final age = _calcAge(_birthday!);

    final newPet = PetInfo(
      petId: _initialPet?.petId,
      userId: _initialPet?.userId,
      name: name,
      breed: breed,
      birthDate: _birthday,
      weightKg: weight,
      heightCm: height,
      age: age,
      gender: _initialPet?.gender,
      photoUrl: _initialPet?.photoUrl,
    );

    try {
      final notifier = ref.read(petProvider.notifier);

      if (_initialPet != null) {
        await notifier.updatePetInfo(_initialPet!.petId.toString(), newPet);
        if (mounted) {
          AppToast.success(context, "$name 정보가 수정되었습니다!");
          Navigator.pop(context);
        }
      } else {
        await notifier.createPetInfo(newPet);
        if (mounted) {
          AppToast.success(context, "$name 등록 완료!");
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, e);
    }
  }

  int _calcAge(DateTime b) {
    final now = DateTime.now();
    int age = now.year - b.year;
    if (now.month < b.month ||
        (now.month == b.month && now.day < b.day)) {
      age--;
    }
    return age;
  }

  Future<void> _pickBirth() async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _birthday ?? DateTime.now().subtract(const Duration(days: 365 * 2)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
      lastDate: DateTime.now(),
      helpText: "생일 선택",
    );

    if (date != null) {
      setState(() => _birthday = date);
    }
  }
}

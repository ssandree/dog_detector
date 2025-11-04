import '../../core/index_export.dart';
import '../../models/pet_info.dart';

class PetRegiScreen extends ConsumerStatefulWidget {
  const PetRegiScreen({super.key});

  @override
  ConsumerState<PetRegiScreen> createState() => _PetRegiScreenState();
}

class _PetRegiScreenState extends ConsumerState<PetRegiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  
  DateTime? _selectedBirthday;
  bool _hasBirthday = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: '강아지 등록',
      body: SingleChildScrollView(
        child: HorizontalPadding(
          child: Form(
            key: _formKey,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 프로필 이미지 섹션
              _buildProfileImageSection(),
              AppConstants.h24,
              
              // 기본 정보 입력 폼
              _buildBasicInfoSection(),
              AppConstants.h24,
              
              // 생일/나이 선택 섹션
              _buildAgeSection(),
              AppConstants.h24,
              
              // 몸무게 입력 섹션
              _buildWeightSection(),
              AppConstants.h32,
              
              // 등록 버튼
              _buildRegisterButton(),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.beige3,
              borderRadius: BorderRadius.circular(60),
              border: Border.all(color: AppColors.grey5, width: 2),
            ),
            child: const Icon(
              Icons.pets,
              size: 60,
              color: AppColors.grey7,
            ),
          ),
          AppConstants.h12,
          TextButton(
            onPressed: () {
              // TODO: 이미지 선택 기능 구현
              // 정보 메시지 표시 - AppToast 사용
              AppToast.info(context, '이미지 선택 기능은 추후 구현됩니다.');
            },
            child: const Text('프로필 사진 추가'),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
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
        const SizedBox(height: 16),
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

  Widget _buildAgeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '나이 정보',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 16),
        
        // 생일 입력 여부 선택
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('생일로 입력'),
                value: true,
                groupValue: _hasBirthday,
                onChanged: (value) {
                  setState(() {
                    _hasBirthday = value!;
                    if (!_hasBirthday) {
                      _selectedBirthday = null;
                      _ageController.clear();
                    }
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('나이로 입력'),
                value: false,
                groupValue: _hasBirthday,
                onChanged: (value) {
                  setState(() {
                    _hasBirthday = value!;
                    if (_hasBirthday) {
                      _ageController.clear();
                    }
                  });
                },
              ),
        ),
      ],
      ),
      
      AppConstants.h16,
        
        // 생일 또는 나이 입력 필드
        if (_hasBirthday) ...[
          InkWell(
            onTap: _selectBirthday,
            child: Container(
              padding: const EdgeInsets.all(16),
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
                        color: _selectedBirthday != null ? AppColors.black : AppColors.grey7,
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
        ] else ...[
          TextFormField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '나이',
              hintText: '나이를 입력해주세요',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.cake),
              suffixText: '살',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '나이를 입력해주세요';
              }
              final age = int.tryParse(value);
              if (age == null || age < 0 || age > 30) {
                return '올바른 나이를 입력해주세요 (0-30살)';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildWeightSection() {
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
        const SizedBox(height: 16),
        TextFormField(
          controller: _weightController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
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

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _registerPet,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.green6,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text(
        '강아지 등록하기',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _selectBirthday() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 2)), // 기본 2살
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 30)), // 최대 30살
      lastDate: DateTime.now(),
      helpText: '생일 선택',
    );

    if (selectedDate != null && mounted) {
      setState(() {
        _selectedBirthday = selectedDate;
      });
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

  Future<void> _registerPet() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final weight = double.parse(_weightController.text.trim());
    
    int? age;
    DateTime? birthday;
    
    if (_hasBirthday && _selectedBirthday != null) {
      birthday = _selectedBirthday!;
      age = _calculateAge(birthday);
    } else if (!_hasBirthday && _ageController.text.isNotEmpty) {
      age = int.parse(_ageController.text.trim());
      birthday = DateTime.now().subtract(Duration(days: age * 365));
    }

    final petInfo = PetInfo(
      name: name,
      age: age,
      birthday: birthday,
      weight: weight,
    );

    try {
      // Riverpod provider를 사용하여 반려동물 정보 저장
      await ref.read(petProvider.notifier).createPetInfo(petInfo);
      
      if (mounted) {
        // 성공 메시지 표시 - AppToast 사용
        AppToast.success(context, '$name이(가) 성공적으로 등록되었습니다!');
        
        // 이전 화면으로 돌아가기
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        // 에러 메시지 표시 - AppToast 사용
        AppToast.error(context, '등록에 실패했습니다. 다시 시도해주세요.');
      }
    }
  }
}

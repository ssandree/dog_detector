import '../../../core/index_export.dart';
import 'widgets/widget_export.dart';

class PetRegiScreen extends ConsumerStatefulWidget {
  final PetInfo? existingPetInfo;
  
  const PetRegiScreen({
    super.key,
    this.existingPetInfo,
  });

  @override
  ConsumerState<PetRegiScreen> createState() => _PetRegiScreenState();
}

class _PetRegiScreenState extends ConsumerState<PetRegiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageSectionKey = GlobalKey<AgeSectionState>();
  
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    // widget.existingPetInfo가 있으면 초기화
    if (widget.existingPetInfo != null) {
      _initializeForm(widget.existingPetInfo!);
    }
  }
  
  void _initializeForm(PetInfo petInfo) {
    if (_isInitialized) return;
    
    _nameController.text = petInfo.name;
    _weightController.text = petInfo.weight.toString();
    
    // AgeSection은 initialBirthday와 initialHasBirthday를 통해 초기화됨
    if (petInfo.age != null && petInfo.birthday == null) {
      _ageController.text = petInfo.age.toString();
    }
    _isInitialized = true;
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Provider에서 현재 반려동물 정보 로드 (widget.existingPetInfo가 없을 때만)
    if (!_isInitialized && widget.existingPetInfo == null) {
      final petInfo = ref.read(currentPetProvider);
      if (petInfo != null) {
        _initializeForm(petInfo);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 기존 정보가 있으면 수정 모드, 없으면 등록 모드
    final isEditMode = widget.existingPetInfo != null;
    
    return BaseScaffold(
      title: isEditMode ? '강아지 정보 수정' : '강아지 등록',
      body: SingleChildScrollView(
        child: HorizontalPadding(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppConstants.h12,
                // 프로필 이미지 섹션
                const ProfileImageSection(),
                AppConstants.h24,
                
                // 기본 정보 입력 폼
                BasicInfoSection(
                  nameController: _nameController,
                ),
                AppConstants.h24,
                
                // 생일/나이 선택 섹션
                AgeSection(
                  key: _ageSectionKey,
                  ageController: _ageController,
                  initialBirthday: widget.existingPetInfo?.birthday,
                  initialHasBirthday: widget.existingPetInfo?.birthday != null,
                ),
                AppConstants.h24,
                
                // 몸무게 입력 섹션
                WeightSection(
                  weightController: _weightController,
                ),
                AppConstants.h32,
                
                // 등록 버튼
                AppButtons.primary(
                  text: isEditMode ? '정보 수정하기' : '강아지 등록하기',
                  onPressed: _registerPet,
                  backgroundColor: AppColors.green6,
                  height: 56,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _registerPet() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final weight = double.parse(_weightController.text.trim());
    
    final ageSectionState = _ageSectionKey.currentState;
    final hasBirthday = ageSectionState?.hasBirthday ?? false;
    final selectedBirthday = ageSectionState?.selectedBirthday;
    
    int? age;
    DateTime? birthday;
    
    if (hasBirthday && selectedBirthday != null) {
      birthday = selectedBirthday;
      age = _calculateAge(birthday);
    } else if (!hasBirthday && _ageController.text.isNotEmpty) {
      age = int.parse(_ageController.text.trim());
      birthday = DateTime.now().subtract(Duration(days: age * 365));
    }

    final petInfo = PetInfo(
      name: name,
      age: age,
      birthday: birthday,
      weight: weight,
      breed: widget.existingPetInfo?.breed,
      gender: widget.existingPetInfo?.gender,
      photoUrl: widget.existingPetInfo?.photoUrl,
    );

    try {
      final petNotifier = ref.read(petProvider.notifier);
      
      if (widget.existingPetInfo != null) {
        // 수정 모드: 기존 정보 업데이트
        // TODO: 실제 petId 사용 (현재는 mock 데이터이므로 임시로 'current' 사용)
        await petNotifier.updatePetInfo('current', petInfo);
        
        if (mounted) {
          AppToast.success(context, '$name의 정보가 성공적으로 수정되었습니다!');
          context.pop();
        }
      } else {
        // 등록 모드: 새 정보 생성
        await petNotifier.createPetInfo(petInfo);
        
        if (mounted) {
          AppToast.success(context, '$name이(가) 성공적으로 등록되었습니다!');
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        final action = widget.existingPetInfo != null ? '수정' : '등록';
        AppToast.error(context, '$action에 실패했습니다. 다시 시도해주세요.');
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
}

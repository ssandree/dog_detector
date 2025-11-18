import '../../../../core/index_export.dart';

class AgeSection extends StatefulWidget {
  final TextEditingController ageController;
  final DateTime? initialBirthday;
  final bool initialHasBirthday;

  const AgeSection({
    super.key,
    required this.ageController,
    this.initialBirthday,
    this.initialHasBirthday = false,
  });

  @override
  State<AgeSection> createState() => AgeSectionState();
}

class AgeSectionState extends State<AgeSection> {
  late bool _hasBirthday;
  late DateTime? _selectedBirthday;

  @override
  void initState() {
    super.initState();
    _hasBirthday = widget.initialHasBirthday;
    _selectedBirthday = widget.initialBirthday;
  }

  @override
  Widget build(BuildContext context) {
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
        AppConstants.h16,
        
        // 생일 입력 여부 선택 (Segmented Control 스타일)
        Container(
          decoration: BoxDecoration(
            color: AppColors.grey1,
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            border: Border.all(color: AppColors.grey3, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _hasBirthday = true;
                      widget.ageController.clear();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _hasBirthday ? AppColors.green6 : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                    ),
                    child: Text(
                      '생일로 입력',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _hasBirthday ? AppColors.white : AppColors.black,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _hasBirthday = false;
                      _selectedBirthday = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_hasBirthday ? AppColors.green6 : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                    ),
                    child: Text(
                      '나이로 입력',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: !_hasBirthday ? AppColors.white : AppColors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        AppConstants.h16,
        
        // 생일 또는 나이 입력 필드
        if (_hasBirthday) ...[
          InkWell(
            onTap: _selectBirthday,
            child: Container(
              height: 56, // TextFormField와 동일한 높이로 통일
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
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
          SizedBox(
            height: 56, // 생일 입력칸과 동일한 높이로 통일
            child: TextFormField(
              controller: widget.ageController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                labelText: '나이',
                hintText: '나이를 입력해주세요',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cake),
                suffixText: '살',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          ),
        ],
      ],
    );
  }

  Future<void> _selectBirthday() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime.now().subtract(const Duration(days: 365 * 2)),
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

  int _calculateAge(DateTime birthday) {
    final now = DateTime.now();
    int age = now.year - birthday.year;
    if (now.month < birthday.month || 
        (now.month == birthday.month && now.day < birthday.day)) {
      age--;
    }
    return age;
  }

  // 외부에서 상태를 가져오기 위한 getter
  bool get hasBirthday => _hasBirthday;
  DateTime? get selectedBirthday => _selectedBirthday;
}


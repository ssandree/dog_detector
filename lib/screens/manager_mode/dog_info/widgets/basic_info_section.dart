import '../../../../core/index_export.dart';

class BasicInfoSection extends StatelessWidget {
  final TextEditingController nameController;

  const BasicInfoSection({
    super.key,
    required this.nameController,
  });

  @override
  Widget build(BuildContext context) {
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
          controller: nameController,
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
}


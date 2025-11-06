import '../../../../core/index_export.dart';

class WeightSection extends StatelessWidget {
  final TextEditingController weightController;

  const WeightSection({
    super.key,
    required this.weightController,
  });

  @override
  Widget build(BuildContext context) {
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
          controller: weightController,
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
}


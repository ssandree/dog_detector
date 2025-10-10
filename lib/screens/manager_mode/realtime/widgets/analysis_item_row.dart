import 'package:flutter/material.dart';
import '../../../../core/index_export.dart';

/// 분석 결과 아이템을 표시하는 행 위젯
class AnalysisItemRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color valueColor;

  const AnalysisItemRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: valueColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.circularBorderRadius - 30),
          ),
          child: Icon(
            icon,
            size: AppConstants.defaultIconSize - 4,
            color: valueColor,
          ),
        ),
        const SizedBox(width: AppConstants.defaultSpacing - 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: AppConstants.smallFontSize + 2,
                  color: AppColors.grey6,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: AppConstants.defaultFontSize,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

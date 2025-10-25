import 'package:flutter/material.dart';
import '../../../../core/index_export.dart';

class MonthlySummary extends StatelessWidget {
  final String title;
  final String summaryText;
  final List<String> bulletPoints;

  const MonthlySummary({
    super.key,
    required this.title,
    required this.summaryText,
    required this.bulletPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: AppConstants.titleFontSize - 4,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.defaultSpacing - 1),
        Container(
          padding: const EdgeInsets.all(AppConstants.defaultSpacing - 1),
          decoration: BoxDecoration(
            color: AppColors.green1,
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius + 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                summaryText,
                style: const TextStyle(
                  fontSize: AppConstants.defaultFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.smallSpacing),
              Text(
                bulletPoints.map((point) => '• $point').join('\n'),
                style: const TextStyle(
                  fontSize: AppConstants.defaultFontSize - 2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

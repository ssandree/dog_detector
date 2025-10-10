import 'package:flutter/material.dart';
import '../../../../core/index_export.dart';

class AiReportSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final String statusLabel;
  final Color statusColor;
  final List<String> analysisTexts;
  final List<String> guideItems;

  const AiReportSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.statusColor,
    required this.analysisTexts,
    required this.guideItems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppConstants.cameraSettingPadding,
      decoration: BoxDecoration(
        color: AppColors.grey1,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: AppConstants.titleFontSize - 4,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.smallSpacing,
                  vertical: AppConstants.smallSpacing - 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                ),
                child: Text(
                  statusLabel,
                  style: const TextStyle(
                    fontSize: AppConstants.smallFontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallSpacing),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: AppConstants.defaultFontSize - 2,
              color: AppColors.grey7,
            ),
          ),
          const SizedBox(height: AppConstants.defaultSpacing),
          ...analysisTexts.map((text) => Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.smallSpacing + 4),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: AppConstants.defaultFontSize,
                color: AppColors.black,
                height: 1.4,
              ),
            ),
          )),
          const SizedBox(height: AppConstants.defaultSpacing + 4),
          const Text(
            '보호자 가이드',
            style: TextStyle(
              fontSize: AppConstants.titleFontSize - 6,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: AppConstants.smallSpacing + 4),
          ...guideItems.map((item) => _buildGuideItem(item)),
        ],
      ),
    );
  }

  Widget _buildGuideItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.smallSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(
              top: AppConstants.smallSpacing - 2,
              right: AppConstants.smallSpacing,
            ),
            width: AppConstants.smallSpacing - 4,
            height: AppConstants.smallSpacing - 4,
            decoration: const BoxDecoration(
              color: AppColors.green5,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: AppConstants.defaultFontSize - 2,
                color: AppColors.black,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

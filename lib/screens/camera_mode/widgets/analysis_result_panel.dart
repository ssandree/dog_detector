import '../../../core/index_export.dart';

class AnalysisResultPanel extends StatelessWidget {
  const AnalysisResultPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCards.basic(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '분석 결과',
            style: TextStyle(
              fontSize: AppConstants.titleFontSize - 4,
              fontWeight: FontWeight.bold,
              color: AppColors.analysisResultTitleColor,
            ),
          ),
          const SizedBox(height: AppConstants.defaultSpacing),
          const Text('AI 분석 비활성화 상태입니다.'),
        ],
      ),
    );
  }
}



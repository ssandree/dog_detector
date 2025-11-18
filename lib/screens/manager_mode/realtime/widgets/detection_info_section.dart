import '../../../../core/index_export.dart';
import 'analysis_item_row.dart';

/// 실시간 감시 지표 요약 섹션
class DetectionInfoSection extends StatelessWidget {
  const DetectionInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCards.basic(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '실시간 감시 요약',
            style: TextStyle(
              fontSize: AppConstants.titleFontSize - 6,
              fontWeight: FontWeight.bold,
              color: AppColors.grey12,
            ),
          ),
          AppConstants.h12,
          const AnalysisItemRow(
            icon: Icons.pets,
            title: '최근 강아지 감지 시간',
            value: '오늘 오후 2:35',
            valueColor: AppColors.success,
          ),
          AppConstants.h12,
          const AnalysisItemRow(
            icon: Icons.videocam,
            title: '카메라 총 가동시간',
            value: '6시간 20분',
            valueColor: AppColors.analysisResultTitleColor,
          ),
        ],
      ),
    );
  }
}


import '../../../../core/index_export.dart';

class AiReportSection extends StatelessWidget {
  final Map<String, dynamic> reportData;
  final Map<String, int> emotionCounts;
  final int healthAlertCount;
  final String title;
  final String statusLabel;
  final Color statusColor;

  const AiReportSection({
    super.key,
    required this.reportData,
    required this.emotionCounts,
    required this.healthAlertCount,
    this.title = 'AI 리포트',
    this.statusLabel = '관심 필요',
    this.statusColor = AppColors.green5,
  });

  @override
  Widget build(BuildContext context) {
    // AI 리포트 텍스트
    final aiComment = reportData['aiComment'] as String? ?? '오늘 도도의 하루를 AI가 요약했어요!';
    
    // 감정 비율 계산
    final positiveEmotions = ['행복', '편안'];
    final negativeEmotions = ['불안', '화남', '공포', '공격성'];
    int positiveCount = 0;
    int negativeCount = 0;
    for (var entry in emotionCounts.entries) {
      if (positiveEmotions.contains(entry.key)) {
        positiveCount += entry.value;
      } else if (negativeEmotions.contains(entry.key)) {
        negativeCount += entry.value;
      }
    }
    final totalEmotionCount = positiveCount + negativeCount;
    final negativePercent = totalEmotionCount > 0 ? (negativeCount / totalEmotionCount * 100).round() : 0;
    final positivePercent = totalEmotionCount > 0 ? (positiveCount / totalEmotionCount * 100).round() : 0;
    
    // 분석 텍스트 생성
    final analysisTexts = [
      '하루 중 부정적인 감정이 $negativePercent%로 긍정적인 감정 $positivePercent%보다 ${negativePercent > positivePercent ? '높았습니다' : '낮았습니다'}.',
      '오늘 슬개골 탈구 의심 행동이 총 $healthAlertCount회 감지되었습니다. 현재 단계는 \'관심\'에 해당하며, 무릎 관절에 부담이 있었을 수 있으니 보호자의 관찰이 필요합니다.',
    ];
    
    // 가이드 아이템
    final guideItems = [
      '오늘은 무리한 산책이나 계단 오르내리기, 잦은 점프 같은 활동은 피하는 것이 좋습니다.',
      '내일도 같은 행동이 반복된다면 가까운 동물병원에 상담을 권장합니다.',
      '대신 가벼운 산책이나 실내 놀이를 통해 스트레스를 완화시켜주는 것이 도도의 정서 안정에도 도움이 될 수 있습니다.',
    ];

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
            aiComment,
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

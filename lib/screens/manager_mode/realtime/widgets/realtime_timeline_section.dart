import '../../../../core/index_export.dart';

class _TimelineEntry {
  const _TimelineEntry({
    required this.timeLabel,
    required this.summary,
  });

  final String timeLabel;
  final String summary;
}

/// 최근 강아지 감지 타임라인
class RealtimeTimelineSection extends StatelessWidget {
  const RealtimeTimelineSection({super.key});

  static const _entries = [
    _TimelineEntry(
      timeLabel: '30분 전',
      summary: '식사 후 휴식 중 안정적인 호흡 패턴 확인',
    ),
    _TimelineEntry(
      timeLabel: '1시간 전',
      summary: '거실에서 낮은 긴장도 움직임 감지',
    ),
    _TimelineEntry(
      timeLabel: '2시간 전',
      summary: '산책 후 물 섭취 행동 탐지',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCards.basic(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '최근 타임라인',
            style: TextStyle(
              fontSize: AppConstants.titleFontSize - 6,
              fontWeight: FontWeight.bold,
              color: AppColors.grey12,
            ),
          ),
          AppConstants.h16,
          ..._entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.defaultSpacing),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                    child: Image.asset(
                      'lib/config/puppy.jpg',
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: AppConstants.defaultSpacing),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.timeLabel,
                          style: const TextStyle(
                            fontSize: AppConstants.smallFontSize + 2,
                            fontWeight: FontWeight.w600,
                            color: AppColors.coral4,
                          ),
                        ),
                        AppConstants.h4,
                        Text(
                          entry.summary,
                          style: const TextStyle(
                            fontSize: AppConstants.defaultFontSize - 2,
                            color: AppColors.grey8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


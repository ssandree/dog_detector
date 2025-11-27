import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

import '../../../../core/app_constants.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/models/event_info.dart';
import '../detection_clue_modal.dart';

class EventCard extends StatelessWidget {
  final EventInfo event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final start = _formatTime(event.startTime);
    final end = _formatTime(event.endTime);
    final emotion = event.finalEmotion ?? '분석 중';
    final statusColor = _statusColor(event.analysisStatus);

    return InkWell(
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) => DetectionClueModal(event: event),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.timeline,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$start ~ $end',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.grey12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    emotion,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${event.videoDurationSec}s',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.grey7,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    event.analysisStatus == AnalysisStatus.completed
                        ? '완료'
                        : event.analysisStatus == AnalysisStatus.pending
                            ? '대기'
                            : '실패',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Color _statusColor(AnalysisStatus status) {
    switch (status) {
      case AnalysisStatus.completed:
        return AppColors.green6;
      case AnalysisStatus.pending:
        return AppColors.warning;
      case AnalysisStatus.failed:
      default:
        return AppColors.error;
    }
  }
}

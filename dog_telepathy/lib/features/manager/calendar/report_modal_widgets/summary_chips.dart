import 'package:flutter/material.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/models/event_info.dart';

class SummaryChips extends StatelessWidget {
  final DailyStats stats;

  const SummaryChips({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryChip(
            label: '전체',
            value: '${stats.totalEvents}건',
            color: AppColors.green6,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryChip(
            label: '총 영상 길이',
            value: stats.totalDurationLabel,
            color: AppColors.good,
          ),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.grey8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class DailyStats {
  final int totalEvents;
  final int completedEvents;
  final int pendingEvents;
  final int totalDurationSeconds;

  DailyStats({
    required this.totalEvents,
    required this.completedEvents,
    required this.pendingEvents,
    required this.totalDurationSeconds,
  });

  factory DailyStats.fromEvents(List<EventInfo> events) {
    final total = events.length;
    final completed = events.where(
      (event) => event.analysisStatus == AnalysisStatus.completed,
    ).length;
    final pending = events.where(
      (event) => event.analysisStatus == AnalysisStatus.pending,
    ).length;
    final duration = events.fold<int>(
      0,
      (sum, event) => sum + event.videoDurationSec,
    );

    return DailyStats(
      totalEvents: total,
      completedEvents: completed,
      pendingEvents: pending,
      totalDurationSeconds: duration,
    );
  }

  String get totalDurationLabel {
    final minutes = (totalDurationSeconds / 60).floor();
    final seconds = totalDurationSeconds % 60;
    if (minutes == 0) return '${seconds}s';
    return '${minutes}분 ${seconds.toString().padLeft(2, '0')}초';
  }
}


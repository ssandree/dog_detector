// lib/widgets/report/chart_summary_card.dart
// 요약 통계 카드
// - 총 감정 분석 건수, 긍정/부정/중립 비율, 상위 감정 표시
// - 캐시 데이터 표시 시 오프라인 아이콘 출력

import 'package:flutter/material.dart';
import '../../models/analytics_summary.dart';

class ChartSummaryCard extends StatelessWidget {
  final AnalyticsSummary summary;
  final bool fromCache;

  const ChartSummaryCard({
    super.key,
    required this.summary,
    this.fromCache = false,
  });

  @override
  Widget build(BuildContext context) {
    final posRate =
        summary.total == 0 ? 0.0 : (summary.positive / summary.total) * 100;
    final negRate =
        summary.total == 0 ? 0.0 : (summary.negative / summary.total) * 100;
    final neuRate =
        summary.total == 0 ? 0.0 : (summary.neutral / summary.total) * 100;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '요약 통계',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (fromCache)
                  const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(Icons.cloud_off, size: 16),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 24,
              runSpacing: 8,
              children: [
                _metric('총 분석', summary.total.toString()),
                _metric('긍정', '${posRate.toStringAsFixed(1)}%'),
                _metric('부정', '${negRate.toStringAsFixed(1)}%'),
                _metric('중립', '${neuRate.toStringAsFixed(1)}%'),
              ],
            ),
            if (summary.topEmotions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Top 감정: ${summary.topEmotions.take(3).join(', ')}',
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// lib/screens/report/analytics_dashboard_screen.dart
// 분석 대시보드 화면
// - 감정 분석 요약 카드, 트렌드 차트, 카메라별 통계 표시
// - Riverpod Provider로 실시간 데이터 상태 반영
// - 오프라인 시 Hive 캐시 기반 표시

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/providers/analytics_provider.dart';
import '../../widgets/report/chart_summary_card.dart';
import '../../widgets/report/trend_chart.dart';
import '../../widgets/report/camera_distribution_chart.dart';

class AnalyticsDashboardScreen extends HookConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('분석 리포트'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(analyticsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: state.when(
        data: (bundle) {
          if (bundle == null) {
            return const Center(child: Text('데이터가 없습니다.'));
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(analyticsProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ChartSummaryCard(
                  summary: bundle.summary,
                  fromCache: false,
                ),
                const SizedBox(height: 12),
                TrendChart(points: bundle.trend),
                const SizedBox(height: 12),
                CameraDistributionChart(cameraStats: bundle.camera),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            '데이터 로드 실패: $e',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}

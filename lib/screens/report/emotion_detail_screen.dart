// lib/screens/report/emotion_detail_screen.dart
// 감정 상세 리포트 화면
// - 선택된 날짜 또는 세션의 감정별 분석 결과 표시
// - 감정명, 확률, 근거 영상 URL, 카메라 ID 기반 상세 보기 제공

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/providers/analytics_provider.dart';
import '../../models/emotion_report.dart';
import '../../core/utils/analytics_formatter.dart';

class EmotionDetailScreen extends HookConsumerWidget {
  final String? id;
  const EmotionDetailScreen({super.key, this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analyticsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('감정 상세 리포트')),
      body: state.when(
        data: (bundle) {
          if (bundle == null) {
            return const Center(child: Text('데이터가 없습니다.'));
          }

          // 서버 연동 전 임시 더미 데이터 사용
          final reports = _mockReports();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: reports.length,
            itemBuilder: (context, i) {
              final r = reports[i];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.videocam, size: 36),
                  title: Text(
                    '${r.emotion} (${(r.confidence * 100).toStringAsFixed(1)}%)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${AnalyticsFormatter.date(r.date)} | Camera ${r.cameraId}',
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            '오류 발생: $e',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  // 서버 데이터 연동 전 임시 샘플
  List<EmotionReport> _mockReports() => [
        EmotionReport(
          emotion: '행복',
          confidence: 0.92,
          date: DateTime.now().subtract(const Duration(hours: 1)),
          videoUrl: '',
          cameraId: 1,
        ),
        EmotionReport(
          emotion: '놀람',
          confidence: 0.84,
          date: DateTime.now().subtract(const Duration(hours: 3)),
          videoUrl: '',
          cameraId: 2,
        ),
        EmotionReport(
          emotion: '슬픔',
          confidence: 0.77,
          date: DateTime.now().subtract(const Duration(hours: 5)),
          videoUrl: '',
          cameraId: 1,
        ),
      ];
}

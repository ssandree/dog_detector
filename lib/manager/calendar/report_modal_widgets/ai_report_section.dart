import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/config/app_constants.dart';
import '../../../../core/config/app_colors.dart';
import '../../logic/provider/ai_report_provider.dart';

class AiReportSection extends StatelessWidget {
  final AsyncValue<DailyAiReport> reportAsync;

  const AiReportSection({
    super.key,
    required this.reportAsync,
  });

  @override
  Widget build(BuildContext context) {
    return reportAsync.when(
      data: (report) {
        // 리포트가 비어있으면 "리포트 없음" 메시지 표시
        if (!report.hasSummary) {
          return const AiReportEmptyCard();
        }
        return AiReportCard(summary: report.summary);
      },
      loading: () => const AiReportLoadingCard(),
      error: (error, _) {
        // 404 에러인 경우 "리포트 없음" 메시지 표시
        final errorStr = error.toString();
        if (errorStr.contains('404') || 
            errorStr.contains('찾을 수 없습니다') ||
            errorStr.contains('분석된 영상 기록이 없습니다')) {
          return const AiReportEmptyCard();
        }
        return AiReportErrorCard(message: error.toString());
      },
    );
  }
}

class AiReportCard extends StatelessWidget {
  final String summary;

  const AiReportCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final content = summary.trim().isEmpty
        ? 'AI 리포트를 아직 생성하지 못했어요.\n조금 뒤 다시 시도해 주세요.'
        : summary.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.beige1.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.auto_awesome,
                color: AppColors.green6,
              ),
              SizedBox(width: 8),
              Text(
                'AI 리포트',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.grey12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              height: 1.45,
              color: AppColors.grey9,
            ),
          ),
        ],
      ),
    );
  }
}

class AiReportLoadingCard extends StatelessWidget {
  const AiReportLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.grey1,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      ),
      child: Row(
        children: const [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text(
            'AI 리포트를 불러오는 중이에요...',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.grey8,
            ),
          ),
        ],
      ),
    );
  }
}

class AiReportErrorCard extends StatelessWidget {
  final String message;

  const AiReportErrorCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.warning,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'AI 리포트를 불러오지 못했어요.\n$message',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.grey9,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AiReportEmptyCard extends StatelessWidget {
  const AiReportEmptyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.grey1,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.grey7,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '이 날짜에는 분석된 영상 기록이 없어요.\n리포트를 생성할 수 없습니다.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.grey8,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// lib/manager/calendar/calendar_widgets/monthly_ai_report.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/config/app_constants.dart';
import '../../../../core/config/app_colors.dart';
import '../../logic/provider/ai_report_provider.dart';
import '../../logic/provider/calendar_provider.dart';
import '../report_modal_widgets/empty_state.dart';

class MonthlyAiReport extends ConsumerWidget {
  const MonthlyAiReport({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarProvider);
    final petId = calendarState.petId;
    
    if (petId == 0) {
      return const SizedBox.shrink();
    }

    final year = calendarState.year;
    final month = calendarState.month;

    final request = MonthlyReportRequest(
      petId: petId,
      year: year,
      month: month,
    );
    
    final monthlyReportAsync = ref.watch(
      monthlyAiReportProvider(request),
    );

    return monthlyReportAsync.when(
      data: (monthlyReport) {
        if (monthlyReport == null || !monthlyReport.hasSummary) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: const ReportEmptyState(
              title: '이번 달 AI 리포트가 없어요',
              message: '월간 리포트를 생성할 데이터가 아직 충분하지 않아요.',
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${year}년 ${month}월 AI 리포트',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.grey12,
              ),
            ),
            const SizedBox(height: 12),
            _ReportItem(
              summary: monthlyReport.summary,
            ),
          ],
        );
      },
      loading: () {
        return const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Center(
            child: SizedBox(
              height: 60,
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
      error: (error, _) {
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: ReportEmptyState(
            title: 'AI 리포트를 불러오지 못했어요',
            message: error.toString(),
          ),
        );
      },
    );
  }
}

/// 리포트 아이템 위젯
class _ReportItem extends StatelessWidget {
  final String summary;

  const _ReportItem({
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.grey1,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(
          color: AppColors.grey3,
          width: 1,
        ),
      ),
      child: Text(
        summary,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.grey12,
          height: 1.5,
        ),
      ),
    );
  }
}


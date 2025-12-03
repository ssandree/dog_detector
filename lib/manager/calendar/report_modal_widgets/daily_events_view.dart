import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/config/app_colors.dart';
import '../../logic/model/event_info.dart';
import '../../logic/provider/ai_report_provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../event_timeline/widgets/event_card.dart';
import 'ai_report_section.dart';
import 'empty_state.dart';

class DailyEventsView extends StatelessWidget {
  final DateTime selectedDate;
  final DailyPetEvents dailyEvents;
  final AsyncValue<DailyAiReport> reportAsync;
  final Widget? statsSection;
  final Widget? hourlySection;

  const DailyEventsView({
    super.key,
    required this.selectedDate,
    required this.dailyEvents,
    required this.reportAsync,
    this.statsSection,
    this.hourlySection,
  });

  @override
  Widget build(BuildContext context) {
    final events = dailyEvents.events;
    if (events.isEmpty) {
      return const ReportEmptyState(
        title: '이날의 이벤트가 없어요',
        message: '카메라가 감지한 이벤트가 없어서 차트를 그릴 수 없어요.',
      );
    }

    final latestEvents = events.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (statsSection != null) ...[
          statsSection!,
          const SizedBox(height: 16),
        ],
        if (hourlySection != null) ...[
          hourlySection!,
          const SizedBox(height: 16),
        ],
        Text(
          '이벤트 타임라인',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.grey12,
              ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          itemCount: latestEvents.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => EventCard(event: latestEvents[index]),
          separatorBuilder: (_, __) => const SizedBox(height: 8),
        ),
        if (events.length > 5) ...[
          const SizedBox(height: 12),
          AppButton.outline(
            text: '더보기',
            height: 44,
            onPressed: () {
              // 모달 닫기
              Navigator.of(context).pop();
              
              // 날짜를 query parameter로 전달하여 타임라인 탭으로 이동
              final dateStr =
                  selectedDate.toIso8601String().split('T')[0]; // YYYY-MM-DD 형식
              context.go('${AppRoutes.managerHome}?date=$dateStr');
            },
          ),
        ],
        const SizedBox(height: 16),
        AiReportSection(reportAsync: reportAsync),
      ],
    );
  }
}

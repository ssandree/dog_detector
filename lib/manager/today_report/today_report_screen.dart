// lib/manager/today_report/today_report_screen.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/config/app_colors.dart';
import '../logic/provider/ai_report_provider.dart';
import '../../../features/pet/application/current_pet_provider.dart';
import '../logic/provider/event_provider.dart';
import '../../../core/widgets/base_scaffold.dart';
import '../calendar/report_modal_widgets/daily_events_view.dart';
import '../calendar/report_modal_widgets/empty_state.dart';
import '../calendar/report_modal_widgets/hourly_chart.dart';
import '../calendar/report_modal_widgets/summary_chips.dart';

class TodayReportScreen extends ConsumerWidget {
  const TodayReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final selectedDate = DateTime(today.year, today.month, today.day);
    final formattedDate =
        '${selectedDate.year}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.day.toString().padLeft(2, '0')}';

    final petInfo = ref.watch(currentPetProvider);
    final petId = petInfo?.petId;

    Widget buildBodyContent() {
      if (petId == null) {
        return const ReportEmptyState(
          title: '반려견 정보를 찾을 수 없어요',
          message: '마이 펫 정보를 먼저 등록하고 다시 시도해 주세요.',
        );
      }

      final eventRequest = DailyEventRequest(petId: petId, date: selectedDate);
      final reportRequest =
          DailyReportRequest(petId: petId, date: selectedDate);
      final dailyEventsAsync = ref.watch(dailyEventsProvider(eventRequest));
      final dailyReportAsync = ref.watch(dailyAiReportProvider(reportRequest));

      return dailyEventsAsync.when(
        data: (daily) {
          final stats = DailyStats.fromEvents(daily.events);
          final buckets = HourlyBuckets.fromEvents(daily.events);

          return DailyEventsView(
            selectedDate: selectedDate,
            dailyEvents: daily,
            reportAsync: dailyReportAsync,
            statsSection: SummaryChips(stats: stats),
            hourlySection: HourlyChart(buckets: buckets),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ReportEmptyState(
          title: '데이터를 불러오지 못했어요',
          message: error.toString(),
        ),
      );
    }

    return BaseScaffold(
      title: '오늘의 리포트',
      showBackButton: true,
      body: SingleChildScrollView(
        padding: AppConstants.cameraSettingPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedDate,
              style: const TextStyle(
                fontSize: AppConstants.titleFontSize - 6,
                fontWeight: FontWeight.bold,
                color: AppColors.grey12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              petInfo?.name != null
                  ? '${petInfo!.name}의 하루 리포트'
                  : '하루 이벤트 리포트',
              style: const TextStyle(
                fontSize: AppConstants.defaultFontSize - 2,
                color: AppColors.grey8,
              ),
            ),
            SizedBox(height: AppConstants.defaultSpacing),
            buildBodyContent(),
            SizedBox(height: AppConstants.defaultSpacing),
          ],
        ),
      ),
    );
  }
}


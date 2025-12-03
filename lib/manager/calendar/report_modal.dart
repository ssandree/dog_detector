import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/config/app_colors.dart';
import '../logic/provider/ai_report_provider.dart';
import '../../../features/pet/application/current_pet_provider.dart';
import '../logic/provider/event_provider.dart';
import 'report_modal_widgets/daily_events_view.dart';
import 'report_modal_widgets/empty_state.dart';
import 'report_modal_widgets/hourly_chart.dart';
import 'report_modal_widgets/summary_chips.dart';

class CalendarModal extends ConsumerWidget {
  final DateTime currentDate;
  final int day;

  const CalendarModal({
    super.key,
    required this.currentDate,
    required this.day,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = DateTime(currentDate.year, currentDate.month, day);
    final modalHeight = MediaQuery.of(context).size.height * 0.65;
    final formattedDate =
        '${selectedDate.year}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.day.toString().padLeft(2, '0')}';

    final petInfo = ref.watch(currentPetProvider);
    final petId = petInfo?.petId;
  
    // 진짜 리포트모달 내용
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

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          minWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: modalHeight,
            child: Padding(
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
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        bottom: AppConstants.defaultSpacing,
                      ),
                      child: buildBodyContent(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


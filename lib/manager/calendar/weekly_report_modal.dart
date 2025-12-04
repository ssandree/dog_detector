// lib/manager/calendar/weekly_report_modal.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/config/app_colors.dart';
import '../logic/provider/ai_report_provider.dart';
import '../../../features/pet/application/current_pet_provider.dart';
import 'report_modal_widgets/empty_state.dart';

class WeeklyReportModal extends ConsumerWidget {
  final DateTime selectedDate;
  final int year;
  final int month;
  final int week;

  const WeeklyReportModal({
    super.key,
    required this.selectedDate,
    required this.year,
    required this.month,
    required this.week,
  });

  /// 날짜 포맷팅 (YYYY-MM-DD -> M월 D일)
  String _formatDate(DateTime date) {
    return '${date.month}월 ${date.day}일';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modalHeight = MediaQuery.of(context).size.height * 0.65;
    final petInfo = ref.watch(currentPetProvider);
    final petId = petInfo?.petId;

      if (petId == null) {
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
                child: const Center(
                  child: ReportEmptyState(
          title: '반려견 정보를 찾을 수 없어요',
          message: '마이 펫 정보를 먼저 등록하고 다시 시도해 주세요.',
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final reportRequest = WeeklyReportRequest(
        petId: petId,
      year: year,
      month: month,
      week: week,
      );
      final weeklyReportAsync = ref.watch(weeklyAiReportProvider(reportRequest));

      return weeklyReportAsync.when(
        data: (report) {
        // API에서 받은 startDate와 endDate 사용
        String dateRangeText = '';
        if (report != null) {
          dateRangeText = '${_formatDate(report.startDate)} ~ ${_formatDate(report.endDate)}';
        } else {
          // 리포트가 없을 때는 기본값 사용
          final weekStart = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
          final weekEnd = weekStart.add(const Duration(days: 6));
          dateRangeText = '${_formatDate(weekStart)} ~ ${_formatDate(weekEnd)}';
        }

        Widget buildBodyContent() {
          if (report == null) {
            return const ReportEmptyState(
              title: '주간 리포트가 없어요',
              message: '해당 주간의 리포트 데이터가 없습니다.',
            );
          }

          if (!report.hasSummary) {
            return const ReportEmptyState(
              title: '주간 리포트가 없어요',
              message: '해당 주간의 리포트 요약이 없습니다.',
            );
          }

          return Container(
                    padding: EdgeInsets.all(AppConstants.defaultSpacing),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '주간 요약',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.grey12,
                          ),
                        ),
                        SizedBox(height: AppConstants.defaultSpacing),
                        Text(
                          report.summary,
                          style: const TextStyle(
                            fontSize: AppConstants.defaultFontSize,
                            color: AppColors.grey9,
                            height: 1.6,
                          ),
                ),
              ],
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
                        '${selectedDate.month}월 ${week}째주 주간 리포트',
              style: const TextStyle(
                fontSize: AppConstants.titleFontSize - 6,
                fontWeight: FontWeight.bold,
                color: AppColors.grey12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
                        dateRangeText,
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
      },
      loading: () => Center(
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
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      ),
      error: (error, _) => Center(
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
                child: Center(
                  child: ReportEmptyState(
                    title: '데이터를 불러오지 못했어요',
                    message: error.toString(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


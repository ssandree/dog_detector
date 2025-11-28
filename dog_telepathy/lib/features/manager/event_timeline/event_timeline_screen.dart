import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/app_constants.dart';
import '../../../core/provider/ai_report_provider.dart';
import '../../../core/provider/event_provider.dart';
import '../calendar/report_modal_widgets/ai_report_section.dart';
import '../calendar/report_modal_widgets/empty_state.dart';
import '../calendar/report_modal_widgets/hourly_chart.dart';
import '../calendar/report_modal_widgets/summary_chips.dart';
import 'widgets/event_card.dart';

class EventTimelineArgs {
  final int petId;
  final DateTime date;

  const EventTimelineArgs({
    required this.petId,
    required this.date,
  });
}

class EventTimelineRoutePage extends StatelessWidget {
  final GoRouterState state;

  const EventTimelineRoutePage({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final extra = state.extra;
    if (extra is! EventTimelineArgs) {
      return Scaffold(
        appBar: AppBar(title: const Text('오류')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('잘못된 요청입니다.'),
              const SizedBox(height: 16),
              Text('Extra type: ${extra?.runtimeType}'),
              Text('URI: ${state.uri}'),
            ],
          ),
        ),
      );
    }

    return EventTimelineScreen(args: extra);
  }
}

class EventTimelineScreen extends ConsumerWidget {
  final EventTimelineArgs args;

  const EventTimelineScreen({
    super.key,
    required this.args,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventRequest = DailyEventRequest(petId: args.petId, date: args.date);
    final reportRequest = DailyReportRequest(petId: args.petId, date: args.date);

    final dailyEventsAsync = ref.watch(dailyEventsProvider(eventRequest));
    final dailyReportAsync = ref.watch(dailyAiReportProvider(reportRequest));

    return Scaffold(
      appBar: AppBar(
        title: const Text('이벤트 타임라인'),
      ),
      body: dailyEventsAsync.when(
        data: (daily) {
          final events = daily.events;
          if (events.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(AppConstants.defaultSpacing),
                child: const ReportEmptyState(
                  title: '이날의 이벤트가 없어요',
                  message: '카메라가 감지한 이벤트가 없어서 타임라인을 만들 수 없어요.',
                ),
              ),
            );
          }

          final stats = DailyStats.fromEvents(events);
          final buckets = HourlyBuckets.fromEvents(events);
          final dateLabel =
              '${args.date.year}.${args.date.month.toString().padLeft(2, '0')}.${args.date.day.toString().padLeft(2, '0')}';

          return SingleChildScrollView(
            padding: EdgeInsets.all(AppConstants.defaultSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$dateLabel 타임라인',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                AiReportSection(reportAsync: dailyReportAsync),
                const SizedBox(height: 16),
                SummaryChips(stats: stats),
                const SizedBox(height: 16),
                HourlyChart(buckets: buckets),
                const SizedBox(height: 16),
                Text(
                  '이벤트 타임라인',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ...events.map(
                  (event) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: EventCard(event: event),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(AppConstants.defaultSpacing),
            child: ReportEmptyState(
              title: '데이터를 불러오지 못했어요',
              message: error.toString(),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/app_constants.dart';
import '../../../core/widgets/base_scaffold.dart';
import 'calendar_widgets/calendar_section.dart';
import 'calendar_widgets/monthly_chart.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: HorizontalPadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            CalendarSection(modalHorizontalMargin: 24),
            SizedBox(height: AppConstants.defaultSpacing),
            MonthlyEventsChart(),
          ],
        ),
      ),
    );
  }
}

import '../../../core/index_export.dart';
import '../report/daily_report.dart';
import '../report/weekly_report.dart';

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(reportTabProvider);

    switch (currentTab) {
      case 0:
        return const DailyReport();
      case 1:
        return const WeeklyReport();
      default:
        return const SizedBox.shrink();
    }
  }
}

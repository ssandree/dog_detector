import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/report_service.dart';
import '../../models/calendar_data.dart';

/// ReportService Provider
final reportServiceProvider = Provider<ReportService>((ref) {
  return ReportService();
});

/// 주간 리포트 주 시작 날짜 상태를 관리하는 Notifier
/// 현재 주의 시작 날짜(월요일)를 관리하며, 최대 5일 이전까지만 이동 가능
class WeeklyReportDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    // 오늘 날짜의 주 시작일(월요일) 반환
    return _getWeekStart(DateTime.now());
  }

  /// 주의 시작일(월요일) 계산
  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday; // 1(월) ~ 7(일)
    return date.subtract(Duration(days: weekday - 1));
  }

  /// 이전 주로 이동 (최대 5일 이전까지만)
  /// 성공 시 true, 제한에 도달했으면 false 반환
  bool previousWeek() {
    final newDate = state.subtract(const Duration(days: 7));
    final today = DateTime.now();
    final todayWeekStart = _getWeekStart(today);
    final minDate = todayWeekStart.subtract(const Duration(days: 5));
    
    if (newDate.isBefore(minDate)) {
      return false; // 5일 이전 제한에 도달
    }
    
    state = newDate;
    return true;
  }

  /// 다음 주로 이동 (오늘 이후로는 이동 불가)
  bool nextWeek() {
    final newDate = state.add(const Duration(days: 7));
    final today = DateTime.now();
    final todayWeekStart = _getWeekStart(today);
    
    if (newDate.isAfter(todayWeekStart)) {
      return false; // 오늘 이후로는 이동 불가
    }
    
    state = newDate;
    return true;
  }

  /// 이번 주로 이동
  void goToCurrentWeek() {
    state = _getWeekStart(DateTime.now());
  }
}

/// 주간 리포트 날짜 상태를 관리하는 Provider
final weeklyReportDateProvider = NotifierProvider<WeeklyReportDateNotifier, DateTime>(WeeklyReportDateNotifier.new);

/// 주간 리포트 데이터 상태를 관리하는 Provider
/// 주 시작 날짜를 파라미터로 받아 해당 주의 리포트 데이터를 반환
final weeklyReportProvider = FutureProvider.family<Map<String, dynamic>, DateTime>(
  (ref, DateTime weekStartDate) async {
    final reportService = ref.watch(reportServiceProvider);
    return await reportService.getWeeklyReport(weekStartDate);
  },
);

/// 일일 리포트 데이터 상태를 관리하는 Provider
final dailyReportProvider = FutureProvider.family<Map<String, dynamic>, DateTime>(
  (ref, DateTime date) async {
    final reportService = ref.watch(reportServiceProvider);
    return await reportService.getDailyReport(date);
  },
);

/// 월간 리포트 데이터 상태를 관리하는 Provider
final monthlyReportProvider = FutureProvider.family<Map<String, dynamic>, ({int year, int month})>(
  (ref, params) async {
    final reportService = ref.watch(reportServiceProvider);
    return await reportService.getMonthlyReport(params.year, params.month);
  },
);

/// 캘린더 화면용 월간 데이터 상태를 관리하는 Provider
final monthlyCalendarProvider = FutureProvider.family<CalendarData, ({int year, int month})>(
  (ref, params) async {
    final reportService = ref.watch(reportServiceProvider);
    return await reportService.getMonthlyCalendarData(params.year, params.month);
  },
);

/// 리포트 탭 인덱스 상태를 관리하는 Notifier
/// 0: 일별 리포트, 1: 주별 리포트
class ReportTabNotifier extends Notifier<int> {
  @override
  int build() {
    return 0; // 초기값: 일별 리포트
  }

  /// 탭 변경
  void changeTab(int index) {
    if (index >= 0 && index <= 1) {
      state = index;
    }
  }
}

/// 리포트 탭 상태를 관리하는 Provider
final reportTabProvider = NotifierProvider<ReportTabNotifier, int>(ReportTabNotifier.new);

/// 일일 리포트 날짜 상태를 관리하는 Notifier
/// 최대 5일 이전까지만 이동 가능하며, 오늘 이후로는 이동 불가
class DailyReportDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    return DateTime.now(); // 초기값: 오늘
  }

  /// 날짜 변경
  void changeDate(DateTime date) {
    state = date;
  }

  /// 이전 날짜로 이동 (최대 5일 이전까지만)
  /// 성공 시 true, 제한에 도달했으면 false 반환
  bool previousDay() {
    final newDate = state.subtract(const Duration(days: 1));
    final today = DateTime.now();
    final minDate = today.subtract(const Duration(days: 5));
    
    if (newDate.isBefore(minDate)) {
      return false; // 5일 이전 제한에 도달
    }
    
    state = newDate;
    return true;
  }

  /// 다음 날짜로 이동 (오늘 이후로는 이동 불가)
  /// 성공 시 true, 제한에 도달했으면 false 반환
  bool nextDay() {
    final newDate = state.add(const Duration(days: 1));
    final today = DateTime.now();
    
    // 오늘 이후로는 이동 불가 (날짜만 비교, 시간 제외)
    final todayDate = DateTime(today.year, today.month, today.day);
    final newDateOnly = DateTime(newDate.year, newDate.month, newDate.day);
    
    if (newDateOnly.isAfter(todayDate)) {
      return false; // 오늘 이후로는 이동 불가
    }
    
    state = newDate;
    return true;
  }

  /// 오늘로 이동
  void goToToday() {
    state = DateTime.now();
  }
}

/// 일일 리포트 날짜 상태를 관리하는 Provider
final dailyReportDateProvider = NotifierProvider<DailyReportDateNotifier, DateTime>(DailyReportDateNotifier.new);


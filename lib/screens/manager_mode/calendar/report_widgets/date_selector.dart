import '../../../../core/index_export.dart';

/// 주간 리포트 전용 날짜 선택기
/// 오늘 날짜를 기준으로 주간 리포트의 주를 선택할 수 있게 해주는 위젯
class DateSelector extends StatelessWidget {
  /// 현재 선택된 주의 시작일 (월요일)
  final DateTime selectedWeekStart;
  /// 오늘 날짜 (DateTime)
  final DateTime today;
  /// 이전 주로 이동하는 콜백
  final VoidCallback? onPrevious;
  /// 다음 주로 이동하는 콜백
  final VoidCallback? onNext;

  const DateSelector({
    super.key,
    required this.selectedWeekStart,
    required this.today,
    this.onPrevious,
    this.onNext,
  });

  /// 주의 시작일(월요일) 계산
  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday; // 1(월) ~ 7(일)
    return date.subtract(Duration(days: weekday - 1));
  }

  @override
  Widget build(BuildContext context) {
    // 주의 시작일과 종료일 계산
    final weekStart = selectedWeekStart;
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    // 날짜 범위 문자열 생성
    final dateRangeStr =
        '${weekStart.year.toString().substring(2)}.${weekStart.month.toString().padLeft(2, '0')}.${weekStart.day.toString().padLeft(2, '0')} - '
        '${weekEnd.year.toString().substring(2)}.${weekEnd.month.toString().padLeft(2, '0')}.${weekEnd.day.toString().padLeft(2, '0')}';

    // 제목 동적 설정 (이번 주, 지난 주 등)
    final todayWeekStart = _getWeekStart(today);
    final selectedWeekStartOnly = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final todayWeekStartOnly = DateTime(todayWeekStart.year, todayWeekStart.month, todayWeekStart.day);
    final weeksDiff = todayWeekStartOnly.difference(selectedWeekStartOnly).inDays ~/ 7;
    
    String title;
    if (weeksDiff == 0) {
      title = '이번 주';
    } else if (weeksDiff == 1) {
      title = '지난 주';
    } else {
      title = dateRangeStr;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: AppConstants.appBarIconSize),
          onPressed: onPrevious,
        ),
        Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: AppConstants.titleFontSize - 6,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              dateRangeStr,
              style: const TextStyle(
                fontSize: AppConstants.smallFontSize,
                color: AppColors.grey6,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: AppConstants.appBarIconSize),
          onPressed: onNext,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/config/app_constants.dart';
import '../../../../core/config/app_colors.dart';
import '../../logic/provider/event_provider.dart';
import '../../logic/service/event_service.dart';

Future<DateTime?> showEventDatePickerDialog({
  required BuildContext context,
  required int petId,
  required DateTime initialDate,
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (ctx) => _EventDatePickerDialog(
      petId: petId,
      initialDate: initialDate,
    ),
  );
}

class _EventDatePickerDialog extends ConsumerStatefulWidget {
  final int petId;
  final DateTime initialDate;

  const _EventDatePickerDialog({
    required this.petId,
    required this.initialDate,
  });

  @override
  ConsumerState<_EventDatePickerDialog> createState() =>
      _EventDatePickerDialogState();
}

class _EventDatePickerDialogState
    extends ConsumerState<_EventDatePickerDialog> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
    );
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final monthRequest = MonthlyEventRequest(
      petId: widget.petId,
      year: _focusedDay.year,
      month: _focusedDay.month,
    );

    final monthlyAsync = ref.watch(monthlyEventsProvider(monthRequest));
    final daysMap = monthlyAsync.maybeWhen(
      data: (summary) => summary.days,
      orElse: () => <int, MonthlyEventStat>{},
    );

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.defaultSpacing),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '날짜 선택',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.grey12,
              ),
            ),
            const SizedBox(height: 8),
            TableCalendar(
              firstDay:
                  DateTime.now().subtract(const Duration(days: 365 * 2)),
              lastDay: DateTime.now(),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) =>
                  isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey12,
                ),
              ),
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.green2,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: AppColors.green5,
                  shape: BoxShape.circle,
                ),
                outsideDaysVisible: false,
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                Navigator.of(context).pop(
                  DateTime(
                    selectedDay.year,
                    selectedDay.month,
                    selectedDay.day,
                  ),
                );
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final stat = daysMap[day.day];
                  final hasEvents = (stat?.totalEvents ?? 0) > 0;
                  final textColor =
                      hasEvents ? AppColors.grey12 : AppColors.grey6;

                  return Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            hasEvents ? FontWeight.w500 : FontWeight.w400,
                        color: textColor,
                      ),
                    ),
                  );
                },
                todayBuilder: (context, day, focusedDay) {
                  final stat = daysMap[day.day];
                  final hasEvents = (stat?.totalEvents ?? 0) > 0;
                  final textColor =
                      hasEvents ? AppColors.grey12 : AppColors.grey6;

                  return Center(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.green2,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                  );
                },
                selectedBuilder: (context, day, focusedDay) {
                  final stat = daysMap[day.day];
                  final hasEvents = (stat?.totalEvents ?? 0) > 0;
                  final textColor =
                      hasEvents ? Colors.white : AppColors.grey2;

                  return Center(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.green5,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AlarmInfo {
   final bool instantAlert;
   final bool dailySummary;
   final bool monthlyReport;
   final TimeOfDay pushTime;
   final String reportEmail;
   final int reportDay;

   const AlarmInfo({
      this.instantAlert = false,
      this.dailySummary = false,
      this.monthlyReport = false,
      this.pushTime = const TimeOfDay(hour: 9, minute: 0),
      this.reportEmail = '2020020@sju.ac.kr',
      this.reportDay = 28,
   });

  // 불변 객체 복제용
   AlarmInfo copyWith({
      bool? instantAlert,
      bool? dailySummary,
      bool? monthlyReport,
      TimeOfDay? pushTime,
      String? reportEmail,
      int? reportDay,
   }) {
      return AlarmInfo(
      instantAlert: instantAlert ?? this.instantAlert,
      dailySummary: dailySummary ?? this.dailySummary,
      monthlyReport: monthlyReport ?? this.monthlyReport,
      pushTime: pushTime ?? this.pushTime,
      reportEmail: reportEmail ?? this.reportEmail,
         reportDay: reportDay ?? this.reportDay,
      );
   }

  // JSON 직렬화
   Map<String, dynamic> toJson() {
      return {
      'instantAlert': instantAlert,
      'dailySummary': dailySummary,
      'monthlyReport': monthlyReport,
      'pushTime': {
         'hour': pushTime.hour,
         'minute': pushTime.minute,
      },
      'reportEmail': reportEmail,
      'reportDay': reportDay,
      };
   }

  // JSON 역직렬화
   factory AlarmInfo.fromJson(Map<String, dynamic> json) {
      return AlarmInfo(
      instantAlert: json['instantAlert'] as bool? ?? false,
      dailySummary: json['dailySummary'] as bool? ?? false,
      monthlyReport: json['monthlyReport'] as bool? ?? false,
      pushTime: json['pushTime'] != null
            ? TimeOfDay(
               hour: json['pushTime']['hour'] as int,
               minute: json['pushTime']['minute'] as int,
            )
            : const TimeOfDay(hour: 9, minute: 0),
      reportEmail: json['reportEmail'] as String? ?? '2020020@sju.ac.kr',
      reportDay: json['reportDay'] as int? ?? 28,
      );
   }

   @override
   String toString() {
      return 'AlarmInfo(instantAlert: $instantAlert, dailySummary: $dailySummary, monthlyReport: $monthlyReport, pushTime: $pushTime, reportEmail: $reportEmail, reportDay: $reportDay)';
   }

   @override
   bool operator ==(Object other) {
      if (identical(this, other)) return true;
      return other is AlarmInfo &&
         other.instantAlert == instantAlert &&
         other.dailySummary == dailySummary &&
         other.monthlyReport == monthlyReport &&
         other.pushTime == pushTime &&
         other.reportEmail == reportEmail &&
         other.reportDay == reportDay;
   }

   @override
   int get hashCode {
      return instantAlert.hashCode ^
         dailySummary.hashCode ^
         monthlyReport.hashCode ^
         pushTime.hashCode ^
         reportEmail.hashCode ^
         reportDay.hashCode;
   }

  // 시간 포맷팅 헬퍼 메서드
   String get formattedPushTime {
      final hour = pushTime.hourOfPeriod == 0 ? 12 : pushTime.hourOfPeriod;
      final minute = pushTime.minute.toString().padLeft(2, '0');
      final period = pushTime.period == DayPeriod.am ? '오전' : '오후';
      return '$period $hour:$minute';
   }

  // 리포트 전송 날짜 포맷팅 헬퍼 메서드
   String get formattedReportDay => '매달 $reportDay일';
}

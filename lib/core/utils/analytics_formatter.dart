// lib/utils/analytics_formatter.dart
// 분석 데이터 포맷 유틸
// - 날짜, 퍼센트, 소수점 등 표시 형식 통일
// - 리포트/차트에서 공용 사용

import 'package:intl/intl.dart';

class AnalyticsFormatter {
  static final _dateFmt = DateFormat('yyyy.MM.dd');
  static final _timeFmt = DateFormat('HH:mm');
  static final _percentFmt = NumberFormat('0.0');

  // 날짜 포맷
  static String date(DateTime date) => _dateFmt.format(date);

  // 시간 포맷
  static String time(DateTime date) => _timeFmt.format(date);

  // 퍼센트 포맷
  static String percent(double value) =>
      '${_percentFmt.format(value * 100)}%';

  // 확률 포맷
  static String score(double value) =>
      _percentFmt.format(value * 100);

  // 카메라 이름 포맷
  static String cameraName(int id) => 'Camera $id';
}

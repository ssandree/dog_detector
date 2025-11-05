// lib/core/services/analytics_service.dart
// 감정 분석 리포트 통신 로직
// - /analytics 엔드포인트와 통신
// - 요약·트렌드·주간·월간·카메라별 통계 데이터 요청 및 파싱
// - 서버 응답 실패 시 예외 처리 및 로깅

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../models/analytics_summary.dart';
import '../../models/analytics_bundle.dart';

class AnalyticsService {
  AnalyticsService._internal();
  static final AnalyticsService instance = AnalyticsService._internal();

  final _log = Logger();
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://your-server-url.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // 전체 분석 데이터 요청
  Future<AnalyticsBundle> fetchAll() async {
    try {
      final summary = await fetchSummary();
      final trend = await fetchTrend();
      final camera = await fetchCamera();
      final weekly = await fetchWeekly();
      final monthly = await fetchMonthly();

      return AnalyticsBundle(
        summary: summary,
        trend: trend,
        camera: camera,
        weekly: weekly,
        monthly: monthly,
      );
    } catch (e, s) {
      _log.e('Analytics fetch failed', error: e, stackTrace: s);
      rethrow;
    }
  }

  // 요약 리포트 요청
  Future<AnalyticsSummary> fetchSummary() async {
    final res = await _dio.get('/analytics/summary');
    _log.i('Fetched analytics summary');
    return AnalyticsSummary.fromJson(res.data as Map<String, dynamic>);
  }

  // 일간 트렌드 리포트 요청
  Future<List<TrendPoint>> fetchTrend() async {
    final res = await _dio.get('/analytics/trend');
    final list = (res.data as List).cast<Map<String, dynamic>>();
    return list.map(TrendPoint.fromJson).toList();
  }

  // 주간 리포트 요청
  Future<List<TrendPoint>> fetchWeekly() async {
    try {
      final res = await _dio.get('/analytics/weekly');
      final list = (res.data as List).cast<Map<String, dynamic>>();
      return list.map(TrendPoint.fromJson).toList();
    } catch (e) {
      _log.w('Weekly analytics fetch failed, fallback to empty list');
      return [];
    }
  }

  // 월간 리포트 요청
  Future<List<TrendPoint>> fetchMonthly() async {
    try {
      final res = await _dio.get('/analytics/monthly');
      final list = (res.data as List).cast<Map<String, dynamic>>();
      return list.map(TrendPoint.fromJson).toList();
    } catch (e) {
      _log.w('Monthly analytics fetch failed, fallback to empty list');
      return [];
    }
  }

  // 카메라별 통계 요청
  Future<List<CameraStat>> fetchCamera() async {
    final res = await _dio.get('/analytics/camera');
    final list = (res.data as List).cast<Map<String, dynamic>>();
    return list.map(CameraStat.fromJson).toList();
  }
}

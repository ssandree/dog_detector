// lib/core/services/notification_service.dart
// 앱 내 로컬 알림 기능 총괄 서비스
// - 즉시 알림, 예약 알림, 클릭 시 라우팅 처리
// - Android 13+ 및 iOS 권한 요청 포함

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../config/app_routes.dart';
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin _notifications =
    FlutterLocalNotificationsPlugin();

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final navigatorKey = GlobalKey<NavigatorState>();

  // 초기화
  Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (resp) {
        _onSelectNotification(resp.payload);
      },
    );

    // Android 13+ 알림 권한 요청
    final androidImpl = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      await androidImpl.requestNotificationsPermission();
    }
  }

  // 즉시 알림
  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'instant_channel',
      'Instant Notifications',
      channelDescription: '즉시 알림 채널',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // 예약 알림
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled Notifications',
      channelDescription: '예약 알림 채널',
      importance: Importance.defaultImportance,
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // 알림 클릭 시 라우팅
  void _onSelectNotification(String? payload) {
    if (payload == null) return;
    final nav = navigatorKey.currentState;
    if (nav == null) return;

    switch (payload) {
      case AppRoutes.deepLinkReportHome:
        nav.pushNamed(AppRoutes.reportHome);
        break;
      case AppRoutes.deepLinkReportDetail:
        nav.pushNamed(AppRoutes.reportDetail);
        break;
      default:
        nav.pushNamed(AppRoutes.settings);
        break;
    }
  }

  // 모든 알림 취소
  Future<void> cancelAll() async => _notifications.cancelAll();
}

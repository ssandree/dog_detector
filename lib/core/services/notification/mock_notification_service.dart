import 'dart:convert';

import '../../../data/notification_mock.dart';
import '../../../models/notification_message.dart';
import '../../exceptions.dart';
import '../../storage/local_storage_keys.dart';
import '../../storage/local_storage_repository.dart';
import 'notification_service.dart';

class MockNotificationService implements NotificationService {
  final LocalStorageRepository _storage;

  MockNotificationService(this._storage);

  @override
  Future<List<NotificationMessage>> loadNotifications() async {
    try {
      final jsonString = await _storage.loadString(LocalStorageKeys.notificationMessages);
      if (jsonString != null) {
        final decoded = jsonDecode(jsonString);
        if (decoded is! List<dynamic>) {
          throw const FormatException('JSON 형식이 올바르지 않습니다');
        }
        return decoded
            .map((item) => NotificationMessage.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return mockNotificationMessages.map((message) => message.copyWith()).toList();
    } on AppException {
      rethrow;
    } on FormatException catch (e) {
      throw DataException('알림 데이터를 파싱하는데 실패했습니다.', e);
    } catch (e) {
      throw DataException('알림 목록을 불러오는데 실패했습니다.', e);
    }
  }

  @override
  Future<void> saveNotifications(List<NotificationMessage> notifications) async {
    try {
      final jsonList = notifications.map((notification) => notification.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await _storage.saveString(LocalStorageKeys.notificationMessages, jsonString);
    } on AppException {
      rethrow;
    } catch (e) {
      throw DataException('알림 목록을 저장하는데 실패했습니다.', e);
    }
  }

  @override
  Future<void> clearNotifications() async {
    try {
      await _storage.remove(LocalStorageKeys.notificationMessages);
    } on AppException {
      rethrow;
    } catch (e) {
      throw DataException('알림 목록을 초기화하는데 실패했습니다.', e);
    }
  }
}


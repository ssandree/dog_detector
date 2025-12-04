// lib/features/devices/data/device_api_service.dart

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/storage/app_prefs_provider.dart';
import '../model/device_info.dart';

final deviceApiServiceProvider = Provider<DeviceApiService>((ref) {
  final dio = ref.read(apiDioProvider);
  return DeviceApiService(dio, ref);
});

class DeviceApiService {
  final Dio _dio;
  final Ref _ref;
  DeviceApiService(this._dio, this._ref);

  /// 최신 토큰을 헤더에 추가하는 헬퍼 메서드
  Options _getOptionsWithToken() {
    final prefsValue = _ref.read(appPrefsProvider).value;
    final token = prefsValue?.accessToken;
    
    return Options(
      headers: {
        if (token != null && token.isNotEmpty)
          'Authorization': 'Bearer $token',
      },
    );
  }

  Future<List<DeviceInfo>> fetchMyDevices() async {
    final res = await _dio.get(
      '/devices/',
      options: _getOptionsWithToken(),
    );
    final list = res.data as List<dynamic>;
    return list.map((e) => DeviceInfo.fromJson(e)).toList();
  }

  Future<DeviceInfo> createDevice({
    required String deviceName,
    required String deviceType,
  }) async {
    final res = await _dio.post(
      '/devices/',
      data: {
        'device_name': deviceName,
        'device_type': deviceType,
      },
      options: _getOptionsWithToken(),
    );
    return DeviceInfo.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> updateDeviceStatus(int deviceId, String status) async {
    await _dio.put(
      '/devices/$deviceId/status',
      data: {
        'connection_status': status,
      },
      options: _getOptionsWithToken(),
    );
  }
}

class CurrentDeviceIdNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String id) => state = id;
}

class CurrentViewerIdNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String id) => state = id;
}

final currentDeviceIdProvider =
    NotifierProvider<CurrentDeviceIdNotifier, String>(
  CurrentDeviceIdNotifier.new,
);

final currentViewerIdProvider =
    NotifierProvider<CurrentViewerIdNotifier, String>(
  CurrentViewerIdNotifier.new,
);

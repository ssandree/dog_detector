// lib/features/devices/data/device_api_service.dart

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../model/device_info.dart';

final deviceApiServiceProvider = Provider<DeviceApiService>((ref) {
  final dio = ref.read(apiDioProvider);
  return DeviceApiService(dio);
});

class DeviceApiService {
  final Dio _dio;
  DeviceApiService(this._dio);

  Future<List<DeviceInfo>> fetchMyDevices() async {
    final res = await _dio.get('/devices/');
    final list = res.data as List<dynamic>;
    return list.map((e) => DeviceInfo.fromJson(e)).toList();
  }
}

class DevicesNotifier extends AsyncNotifier<List<DeviceInfo>> {
  @override
  Future<List<DeviceInfo>> build() async {
    final api = ref.watch(deviceApiServiceProvider);
    return api.fetchMyDevices();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

final devicesProvider =
    AsyncNotifierProvider<DevicesNotifier, List<DeviceInfo>>(DevicesNotifier.new);

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
    NotifierProvider<CurrentDeviceIdNotifier, String>(CurrentDeviceIdNotifier.new);

final currentViewerIdProvider =
    NotifierProvider<CurrentViewerIdNotifier, String>(CurrentViewerIdNotifier.new);

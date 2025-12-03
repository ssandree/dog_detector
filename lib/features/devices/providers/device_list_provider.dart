// lib/features/devices/providers/device_list_provider.dart

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/device_api_service.dart';
import '../model/device_info.dart';

final deviceListProvider = FutureProvider<List<DeviceInfo>>((ref) async {
  final api = ref.read(deviceApiServiceProvider);
  return api.fetchMyDevices();
});

final cameraDeviceListProvider = FutureProvider<List<DeviceInfo>>((ref) async {
  final devices = await ref.watch(deviceListProvider.future);
  return devices.where((d) => d.deviceType.toUpperCase() == 'CAMERA').toList();
});

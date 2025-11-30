// lib/features/realtime/infrastructure/webrtc_repository.dart

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../core/network/dio_client.dart';
import '../domain/camera_device.dart';
import 'viewer_engine.dart';

final webrtcRepositoryProvider = Provider<WebRtcRepository>((ref) {
  final dio = ref.read(apiDioProvider);
  final viewer = ref.read(viewerEngineProvider);
  return WebRtcRepository(dio: dio, viewer: viewer);
});

class WebRtcRepository {
  final Dio dio;
  final ViewerEngine viewer;

  WebRtcRepository({
    required this.dio,
    required this.viewer,
  });

  Future<List<CameraDevice>> fetchUserDevices() async {
    final res = await dio.get('/devices/');
    final list = (res.data as List<dynamic>?) ?? [];
    return list
        .map((e) => CameraDevice.fromJson(e as Map<String, dynamic>))
        .where((d) => d.type == DeviceType.camera)
        .toList();
  }

  Future<String?> fetchLatestSession(String camId) async {
    final res = await dio.get('/stream/latest-session',
        queryParameters: {'device_id': camId});
    final data = res.data as Map<String, dynamic>?;
    return data?['session_id'] as String?;
  }

  Future<RTCVideoRenderer> viewerStart({
    required String camId,
    required String viewerId,
  }) async {
    return viewer.startViewing(
      cameraDeviceId: camId,
      viewerDeviceId: viewerId,
    );
  }

  Future<void> viewerStop() async {
    await viewer.stop();
  }
}

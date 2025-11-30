// lib/features/webrtc/data/webrtc_api_service.dart

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../model/webrtc_config.dart';
import '../model/webrtc_session.dart';

final webrtcApiServiceProvider = Provider<WebRtcApiService>((ref) {
  final dio = ref.read(apiDioProvider);
  return WebRtcApiService(dio);
});

class WebRtcApiService {
  final Dio _dio;

  WebRtcApiService(this._dio);

  Future<WebRtcConfig> fetchConfig() async {
    final res = await _dio.get(ApiEndpoints.webrtcConfig);
    return WebRtcConfig.fromJson(res.data as Map<String, dynamic>);
  }

  Future<String> sendOffer({
    required String senderDeviceId,
    required String receiverDeviceId,
    required String sdpOffer,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.webrtcOffer,
      data: {
        'sender_device_id': senderDeviceId,
        'receiver_device_id': receiverDeviceId,
        'sdp_offer': sdpOffer,
      },
    );

    final data = res.data as Map<String, dynamic>;
    return data['session_id'] as String;
  }

  Future<String?> fetchOffer({required String sessionId}) async {
    final res = await _dio.get(
      ApiEndpoints.webrtcOffer,
      queryParameters: {'session_id': sessionId},
    );

    final data = res.data as Map<String, dynamic>;
    return data['sdp_offer'] as String?;
  }

  Future<void> sendAnswer({
    required String sessionId,
    required String sdpAnswer,
  }) async {
    await _dio.post(
      ApiEndpoints.webrtcAnswer,
      data: {
        'session_id': sessionId,
        'sdp_answer': sdpAnswer,
      },
    );
  }

  Future<String?> fetchAnswer({required String sessionId}) async {
    final res = await _dio.get(
      ApiEndpoints.webrtcAnswer,
      queryParameters: {'session_id': sessionId},
    );

    final data = res.data as Map<String, dynamic>;
    return data['sdp_answer'] as String?;
  }

  Future<void> sendCandidate({
    required String sessionId,
    required String senderDeviceId,
    required String receiverDeviceId,
    required String candidate,
  }) async {
    await _dio.post(
      ApiEndpoints.webrtcCandidate,
      data: {
        'session_id': sessionId,
        'sender_device_id': senderDeviceId,
        'receiver_device_id': receiverDeviceId,
        'candidate': candidate,
      },
    );
  }

  Future<List<String>> fetchCandidates({
    required String sessionId,
    required String deviceId,
  }) async {
    final res = await _dio.get(
      ApiEndpoints.webrtcCandidates,
      queryParameters: {
        'session_id': sessionId,
        'device_id': deviceId,
      },
    );

    final data = res.data as Map<String, dynamic>;
    final list = data['candidates'] as List<dynamic>? ?? [];
    return list
        .map((e) => (e as Map<String, dynamic>)['candidate'] as String)
        .toList();
  }

  Future<WebRtcSessionInfo?> fetchLatestSession({
    required String deviceId,
  }) async {
    final res = await _dio.get(
      '${ApiEndpoints.baseUrl}/stream/latest-session',
      queryParameters: {'device_id': deviceId},
    );

    if (res.data == null) return null;

    final data = res.data as Map<String, dynamic>;

    if (data['session_id'] == null) {
      return WebRtcSessionInfo(
        sessionId: null,
        senderDeviceId: data['sender_device_id'] as String? ?? '',
        receiverDeviceId: data['receiver_device_id'] as String? ?? '',
      );
    }

    return WebRtcSessionInfo.fromJson(data);
  }
}

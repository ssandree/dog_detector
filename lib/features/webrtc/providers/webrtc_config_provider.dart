// lib/features/webrtc/providers/webrtc_config_provider.dart

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../core/network/api_endpoints.dart';
import '../model/webrtc_config.dart';

final webrtcConfigProvider = FutureProvider<WebRtcConfig>((ref) async {
  final dio = Dio();

  final res = await dio.get(ApiEndpoints.webrtcConfig);

  return WebRtcConfig.fromJson(res.data);
});

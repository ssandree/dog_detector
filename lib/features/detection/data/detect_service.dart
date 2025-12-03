// lib/features/detection/data/detect_service.dart

import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../model/detection_result.dart';

final detectServiceProvider = Provider<DetectService>((ref) {
  final dio = ref.read(inferenceDioProvider);
  return DetectService(dio);
});

class DetectService {
  final Dio _dio;

  DetectService(this._dio);

  Future<DetectionResult> detect({
    required Uint8List frameBytes,
    required String cameraId,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        frameBytes,
        filename: 'frame.jpg',
      ),
      'camera_id': cameraId,
    });

    final response = await _dio.post(
      '/api/detect-realtime',
      data: formData,

      options: Options(
        contentType: "multipart/form-data",
        headers: {
          "X-API-Key": "idontwantdoganymore",
        },
      ),
    );

    return DetectionResult.fromJson(response.data);
  }
}

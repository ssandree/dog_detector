// lib/features/upload/data/upload_service.dart

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../model/upload_queue_item.dart';

final uploadServiceProvider = Provider<UploadService>((ref) {
  final dio = ref.read(apiDioProvider);
  return UploadService(dio);
});

class UploadService {
  final Dio _dio;

  UploadService(this._dio);

  Future<void> uploadEvent(UploadQueueItem item) async {
    final file = File(item.filePath);
    if (!file.existsSync()) {
      throw Exception('업로드할 파일이 존재하지 않습니다: ${item.filePath}');
    }

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        item.filePath,
        filename: file.uri.pathSegments.last,
      ),
      'pet_id': item.petId,
      'device_id': item.deviceId,
      'start_time': item.startTime.toUtc().toIso8601String(),
      'end_time': item.endTime.toUtc().toIso8601String(),
    });

    final response = await _dio.post(
      '/events/upload',
      data: formData,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        '업로드 실패 (status: ${response.statusCode}, data: ${response.data})',
      );
    }

    print('[UploadService] 업로드 성공: ${item.filePath}');
  }
}

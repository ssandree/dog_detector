// lib/features/upload/domain/upload_engine.dart

import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/upload_service.dart';
import '../model/upload_queue_item.dart';

final uploadEngineProvider = Provider<UploadEngine>((ref) {
  final service = ref.read(uploadServiceProvider);
  return UploadEngine(service);
});

class UploadEngine {
  final UploadService _service;

  UploadEngine(this._service);

  final List<UploadQueueItem> _queue = [];
  bool _uploading = false;

  void enqueue(UploadQueueItem item) {
    _queue.add(item);
    print('[UploadEngine] 큐 추가: ${item.filePath}');
    _tryUploadNext();
  }

  Future<void> _tryUploadNext() async {
    if (_uploading) return;
    if (_queue.isEmpty) return;

    if (!await _isOnWifi()) {
      print('[UploadEngine] Wi-Fi 아님 → 업로드 보류');
      return;
    }

    final item = _queue.first;
    _uploading = true;

    try {
      await _service.uploadEvent(item);

      _queue.removeAt(0);
      final file = File(item.filePath);
      if (file.existsSync()) {
        await file.delete();
        print('[UploadEngine] 업로드 완료 후 파일 삭제: ${item.filePath}');
      }
    } catch (e) {
      print('[UploadEngine] 업로드 실패: $e');
    } finally {
      _uploading = false;
      if (_queue.isNotEmpty) {
        _tryUploadNext();
      }
    }
  }

  Future<bool> _isOnWifi() async {
    return true; 
  }
}

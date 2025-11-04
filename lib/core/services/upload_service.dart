// lib/core/services/upload_service.dart
// 조건부 업로드 서비스
// - 네트워크 상태에 따라 즉시 업로드 또는 로컬 저장
// - 오프라인 저장된 파일은 재연결 시 자동 업로드 재시도

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class UploadService {
  UploadService._internal();
  static final UploadService instance = UploadService._internal();

  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://your-server-url.com'));
  final Logger _log = Logger();
  final Connectivity _connectivity = Connectivity();

  // 업로드 진입점
  Future<void> handleUpload(File file) async {
    try {
      final connected = await _isConnected();
      if (connected) {
        await _uploadNow(file);
      } else {
        await _storeLocally(file);
      }
    } catch (e, s) {
      _log.e('Upload handling failed', error: e, stackTrace: s);
      await _storeLocally(file);
    }
  }

  // 네트워크 연결 확인
  Future<bool> _isConnected() async {
    final status = await _connectivity.checkConnectivity();
    return status != ConnectivityResult.none;
  }

  // 즉시 업로드
  Future<void> _uploadNow(File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.uri.pathSegments.last,
        ),
      });

      final res = await _dio.post('/upload', data: formData);
      if (res.statusCode == 200) {
        _log.i('Uploaded: ${file.path}');
        await file.delete();
      } else {
        _log.w('Upload failed (${res.statusCode}), storing locally');
        await _storeLocally(file);
      }
    } catch (e, s) {
      _log.e('Upload error', error: e, stackTrace: s);
      await _storeLocally(file);
    }
  }

  // 오프라인 임시 저장
  Future<void> _storeLocally(File file) async {
    final dir = await _pendingDir();
    final name = file.uri.pathSegments.last;
    final dest = File('${dir.path}/$name');
    await file.copy(dest.path);
    _log.i('Stored locally: ${dest.path}');
  }

  // 대기 업로드 폴더 경로
  Future<Directory> _pendingDir() async {
    final dir = Directory(
      '${(await getApplicationDocumentsDirectory()).path}/pending_uploads',
    );
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  // 오프라인 파일 재업로드
  Future<void> retryPending() async {
    try {
      final dir = await _pendingDir();
      final files = dir.listSync().whereType<File>().toList();
      if (files.isEmpty) return;

      final connected = await _isConnected();
      if (!connected) return;

      for (final file in files) {
        await _uploadNow(file);
      }

      _log.i('Pending uploads retried (${files.length} files)');
    } catch (e, s) {
      _log.e('Retry failed', error: e, stackTrace: s);
    }
  }
}

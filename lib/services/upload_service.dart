// lib/services/upload_service.dart
// 조건부 업로드 서비스
// - 네트워크 상태에 따라 즉시 업로드 또는 로컬 저장
// - 오프라인 저장된 파일은 재연결 시 자동 업로드 재시도

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../core/exceptions.dart';

class UploadService {
  final Dio _dio;
  final Connectivity _connectivity;

  UploadService({
    Dio? dio,
    Connectivity? connectivity,
  })  : _dio = dio ?? Dio(BaseOptions(baseUrl: 'https://your-server-url.com')),
        _connectivity = connectivity ?? Connectivity();

  // 업로드 진입점
  Future<void> handleUpload(File file) async {
    try {
      final connected = await _isConnected();
      if (connected) {
        await _uploadNow(file);
      } else {
        await _storeLocally(file);
      }
    } on AppException {
      rethrow;
    } catch (e) {
      // 네트워크 오류 시 로컬 저장
      try {
        await _storeLocally(file);
      } catch (storeError) {
        throw NetworkException(
          '파일 업로드 및 로컬 저장에 실패했습니다: ${e.toString()}',
          e,
        );
      }
    }
  }

  // 네트워크 연결 확인
  Future<bool> _isConnected() async {
    try {
      final status = await _connectivity.checkConnectivity();
      return status != ConnectivityResult.none;
    } catch (e) {
      // 연결 확인 실패 시 false 반환
      return false;
    }
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
        await file.delete();
      } else {
        throw ServerException(
          '서버 응답 오류: ${res.statusCode}',
          res.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(
          '업로드 타임아웃이 발생했습니다: ${e.message}',
          e,
        );
      } else if (e.response != null) {
        throw ServerException(
          '서버 오류: ${e.response?.statusCode}',
          e.response?.statusCode,
          e,
        );
      } else {
        throw NetworkException(
          '파일 업로드에 실패했습니다: ${e.message}',
          e,
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        '파일 업로드 중 오류가 발생했습니다: ${e.toString()}',
        e,
      );
    }
  }

  // 오프라인 임시 저장
  Future<void> _storeLocally(File file) async {
    try {
      final dir = await _pendingDir();
      final name = file.uri.pathSegments.last;
      final dest = File('${dir.path}/$name');
      await file.copy(dest.path);
    } on AppException {
      rethrow;
    } catch (e) {
      throw DataException(
        '로컬 저장에 실패했습니다: ${e.toString()}',
        e,
      );
    }
  }

  // 대기 업로드 폴더 경로
  Future<Directory> _pendingDir() async {
    try {
      final dir = Directory(
        '${(await getApplicationDocumentsDirectory()).path}/pending_uploads',
      );
      if (!await dir.exists()) await dir.create(recursive: true);
      return dir;
    } catch (e) {
      throw DataException(
        '저장 디렉토리 생성에 실패했습니다: ${e.toString()}',
        e,
      );
    }
  }

  // 오프라인 파일 재업로드
  Future<void> retryPending() async {
    try {
      final dir = await _pendingDir();
      final files = dir.listSync().whereType<File>().toList();
      if (files.isEmpty) return;

      final connected = await _isConnected();
      if (!connected) {
        throw NetworkException('네트워크에 연결되지 않았습니다.');
      }

      for (final file in files) {
        try {
          await _uploadNow(file);
        } catch (e) {
          // 개별 파일 업로드 실패는 계속 진행
          continue;
        }
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        '보류 파일 재업로드에 실패했습니다: ${e.toString()}',
        e,
      );
    }
  }
}

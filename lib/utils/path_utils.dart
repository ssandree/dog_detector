// lib/utils/path_util.dart
// 파일 경로 관리 유틸
// - pending_uploads 폴더 접근
// - 보류 파일 목록 조회 및 삭제
// - 로컬 캐시 파일 관리용 공통 함수

import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PathUtil {
  // pending_uploads 폴더 경로 반환
  static Future<String> pendingPath() async {
    final dir = Directory(
      '${(await getApplicationDocumentsDirectory()).path}/pending_uploads',
    );
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir.path;
  }

  // pending_uploads 폴더 내 파일 목록 조회
  static Future<List<File>> listPendingFiles() async {
    final dir = Directory(await pendingPath());
    if (!await dir.exists()) return [];
    return dir.listSync().whereType<File>().toList();
  }

  // pending_uploads 폴더 내 파일 전체 삭제
  static Future<void> clearPending() async {
    final files = await listPendingFiles();
    for (final file in files) {
      await file.delete();
    }
  }

  // 파일 존재 여부 확인
  static Future<bool> exists(String path) async {
    return File(path).exists();
  }
}

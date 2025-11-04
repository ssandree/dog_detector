// lib/data/repositories/upload_repository.dart
// 업로드 기록 저장소
// 업로드 성공 시 감정 정보·파일 경로·시간을 Hive DB에 저장

import 'package:hive/hive.dart';

class UploadRepository {
  final String boxName = 'upload_logs';

  Future<void> saveUploadLog({
    required String emotion,
    required double probability,
    required String filePath,
  }) async {
    final box = await Hive.openBox(boxName);
    final log = {
      'emotion': emotion,
      'probability': probability,
      'filePath': filePath,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await box.add(log);
  }

  Future<List<Map>> getAllLogs() async {
    final box = await Hive.openBox(boxName);
    return box.values.cast<Map>().toList();
  }

  Future<void> clearLogs() async {
    final box = await Hive.openBox(boxName);
    await box.clear();
  }
}


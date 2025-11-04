// lib/utils/permission_util.dart
// 권한 요청 유틸리티 클래스
// - 카메라·마이크·저장소 권한 요청
// - Android 13(API 33)+ 호환 포함

import 'package:permission_handler/permission_handler.dart';

class PermissionUtil {
  // 카메라 권한 요청
  static Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // 마이크 권한 요청
  static Future<bool> requestMicrophone() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  // 저장소·사진 권한 요청(Android 13 대응)
  static Future<bool> requestStorage() async {
    final hasStorage = await Permission.storage.isGranted;
    final permission = hasStorage ? Permission.storage : Permission.photos;
    final status = await permission.request();
    return status.isGranted;
  }

  // 모든 권한 요청
  static Future<bool> requestAll() async {
    final results = await [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
    ].request();

    // Android 13+ 대응 추가
    if (!results.values.every((s) => s.isGranted)) {
      final photos = await Permission.photos.request();
      return photos.isGranted;
    }
    return true;
  }

  // 권한 상태 단독 확인
  static Future<bool> isGranted(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }
}

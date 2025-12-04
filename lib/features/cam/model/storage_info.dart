// lib/features/cam/model/storage_info.dart

import 'package:flutter/services.dart';

class StorageInfo {
  static const MethodChannel _channel = MethodChannel("storage_info");

  static Future<Map<String, double>> getStorage() async {
    final result = await _channel.invokeMethod<Map>("getStorageInfo");

    final total = (result?["total"] as int).toDouble();
    final free = (result?["free"] as int).toDouble();
    final used = (result?["used"] as int).toDouble();

    return {
      "total": total,
      "free": free,
      "used": used,
    };
  }
}

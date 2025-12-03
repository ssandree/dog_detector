// lib/core/storage/secure_storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod/riverpod.dart';

final secureStorageServiceProvider =
    Provider<SecureStorageService>((ref) => SecureStorageService());

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  Future<void> writeToken(String token) async {
    await _storage.write(key: 'authToken', value: token);
  }

  Future<String?> readToken() async {
    return await _storage.read(key: 'authToken');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'authToken');
  }
}

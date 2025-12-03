// lib/core/storage/token_reset.dart

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'secure_storage_service.dart';
import 'app_prefs_provider.dart';

Future<void> resetAllTokens(WidgetRef ref) async {
  await ref.read(secureStorageServiceProvider).deleteToken();

  await ref.read(appPrefsProvider.notifier).setAccessToken(null);

  print("🔥 Token reset 완료: secure + shared prefs 둘 다 삭제됨");
}

// lib/core/storage/app_prefs_provider.dart

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app_prefs_state.dart';
import 'prefs_service.dart';

class AppPrefsNotifier extends AsyncNotifier<AppPrefsState> {
  @override
  Future<AppPrefsState> build() async {
    final prefs = PrefsService();
    await prefs.init();

    return AppPrefsState(
      hasSeenOnboarding: prefs.getHasSeenOnboarding(),
      savedId: prefs.getSavedId(),
      autoLogin: prefs.getAutoLogin(),
      mode: prefs.getMode(),
      accessToken: prefs.getAccessToken(),
    );
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    final prefs = PrefsService();
    await prefs.setHasSeenOnboarding(value);
    state = AsyncData(state.value!.copyWith(hasSeenOnboarding: value));
  }

  Future<void> setSavedId(String? id) async {
    final prefs = PrefsService();
    await prefs.setSavedId(id);
    state = AsyncData(state.value!.copyWith(savedId: id));
  }

  Future<void> setAutoLogin(bool value) async {
    final prefs = PrefsService();
    await prefs.setAutoLogin(value);
    state = AsyncData(state.value!.copyWith(autoLogin: value));
  }

  Future<void> setMode(String? mode) async {
    final prefs = PrefsService();
    await prefs.setMode(mode);
    state = AsyncData(state.value!.copyWith(mode: mode));
  }

  Future<void> setAccessToken(String? token) async {
    final prefs = PrefsService();
    await prefs.setAccessToken(token);
    state = AsyncData(state.value!.copyWith(accessToken: token));
  }
}

final appPrefsProvider =
    AsyncNotifierProvider<AppPrefsNotifier, AppPrefsState>(
  AppPrefsNotifier.new,
);

// lib/core/storage/app_prefs_state.dart

class AppPrefsState {
  final bool hasSeenOnboarding;
  final String? savedId;
  final bool autoLogin;
  final String? mode;
  final String? accessToken;

  const AppPrefsState({
    required this.hasSeenOnboarding,
    required this.savedId,
    required this.autoLogin,
    required this.mode,
    required this.accessToken,
  });

  AppPrefsState copyWith({
    bool? hasSeenOnboarding,
    String? savedId,
    bool? autoLogin,
    String? mode,
    String? accessToken,
  }) {
    return AppPrefsState(
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      savedId: savedId ?? this.savedId,
      autoLogin: autoLogin ?? this.autoLogin,
      mode: mode ?? this.mode,
      accessToken: accessToken ?? this.accessToken,
    );
  }

  factory AppPrefsState.initial() => const AppPrefsState(
        hasSeenOnboarding: false,
        savedId: null,
        autoLogin: false,
        mode: null,
        accessToken: null,
      );
}

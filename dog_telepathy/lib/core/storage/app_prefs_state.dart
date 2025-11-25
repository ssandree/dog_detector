class AppPrefsState {
  final bool hasSeenOnboarding;
  final String? savedId;
  final bool autoLogin;
  final String? mode;

  const AppPrefsState({
    required this.hasSeenOnboarding,
    required this.savedId,
    required this.autoLogin,
    required this.mode,
  });

  AppPrefsState copyWith({
    bool? hasSeenOnboarding,
    String? savedId,
    bool? autoLogin,
    String? mode,
  }) {
    return AppPrefsState(
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      savedId: savedId ?? this.savedId,
      autoLogin: autoLogin ?? this.autoLogin,
      mode: mode ?? this.mode,
    );
  }

  factory AppPrefsState.initial() => const AppPrefsState(
        hasSeenOnboarding: false,
        savedId: null,
        autoLogin: false,
        mode: null,
      );
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSettingsState {
  final bool pushNotifications;
  final bool promoNotifications;
  final bool isDarkMode;
  final String language;
  final double cacheSizeMb;

  const AppSettingsState({
    this.pushNotifications = true,
    this.promoNotifications = true,
    this.isDarkMode = false,
    this.language = 'Tiếng Việt',
    this.cacheSizeMb = 14.8,
  });

  AppSettingsState copyWith({
    bool? pushNotifications,
    bool? promoNotifications,
    bool? isDarkMode,
    String? language,
    double? cacheSizeMb,
  }) {
    return AppSettingsState(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      promoNotifications: promoNotifications ?? this.promoNotifications,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      cacheSizeMb: cacheSizeMb ?? this.cacheSizeMb,
    );
  }
}

final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettingsState>(
  AppSettingsNotifier.new,
);

class AppSettingsNotifier extends Notifier<AppSettingsState> {
  @override
  AppSettingsState build() => const AppSettingsState();

  void togglePushNotifications(bool value) {
    state = state.copyWith(pushNotifications: value);
  }

  void togglePromoNotifications(bool value) {
    state = state.copyWith(promoNotifications: value);
  }

  void toggleDarkMode(bool value) {
    state = state.copyWith(isDarkMode: value);
  }

  void setLanguage(String lang) {
    state = state.copyWith(language: lang);
  }

  void clearCache() {
    state = state.copyWith(cacheSizeMb: 0.0);
  }
}

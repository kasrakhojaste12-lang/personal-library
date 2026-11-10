import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../localization/locale_provider.dart';

const String _prefThemeModeKey = 'app_theme_mode';

/// Manages theme mode state (system, light, dark) and persistence.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;

  ThemeModeNotifier(this._prefs) : super(_resolveInitialTheme(_prefs));

  static ThemeMode _resolveInitialTheme(SharedPreferences prefs) {
    final savedMode = prefs.getString(_prefThemeModeKey);
    switch (savedMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _prefs.setString(_prefThemeModeKey, mode.name);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeModeNotifier(prefs);
});

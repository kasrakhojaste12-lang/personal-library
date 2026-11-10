import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _prefLocaleKey = 'app_locale_code';

/// Manages application locale state and persistence.
class LocaleNotifier extends StateNotifier<Locale> {
  final SharedPreferences _prefs;

  LocaleNotifier(this._prefs) : super(_resolveInitialLocale(_prefs));

  static Locale _resolveInitialLocale(SharedPreferences prefs) {
    final savedCode = prefs.getString(_prefLocaleKey);
    if (savedCode != null && (savedCode == 'fa' || savedCode == 'en')) {
      return Locale(savedCode);
    }

    // Default follows device language
    final deviceLocale = ui.PlatformDispatcher.instance.locale;
    if (deviceLocale.languageCode == 'fa') {
      return const Locale('fa');
    }
    return const Locale('en');
  }

  Future<void> setLocale(Locale newLocale) async {
    if (newLocale.languageCode != 'fa' && newLocale.languageCode != 'en') return;
    state = newLocale;
    await _prefs.setString(_prefLocaleKey, newLocale.languageCode);
  }

  bool get isPersian => state.languageCode == 'fa';
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main()');
});

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocaleNotifier(prefs);
});

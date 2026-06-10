import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/user_prefs_service.dart';
import '../storage/storage_keys.dart';
import 'providers.dart';

/// Manages app-wide theme mode with persistence.
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier(this._prefsService) : super(ThemeMode.system) {
    _loadTheme();
  }

  final UserPrefsService _prefsService;

  Future<void> _loadTheme() async {
    final index = _prefsService.prefs.getInt(StorageKeys.themeMode);
    if (index != null && index >= 0 && index < ThemeMode.values.length) {
      state = ThemeMode.values[index];
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _prefsService.prefs.setInt(StorageKeys.themeMode, mode.index);
  }

  void toggleTheme() {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setThemeMode(next);
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier(ref.watch(userPrefsServiceProvider));
});

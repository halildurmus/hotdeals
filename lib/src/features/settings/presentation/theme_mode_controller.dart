import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/local_storage_repository.dart';

final themeModeControllerProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>(
        (ref) => ThemeModeController(ref.read),
        name: 'ThemeModeController');

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController(Reader read)
      : _localStorageRepository = read(localStorageRepositoryProvider),
        super(ThemeMode.system) {
    loadThemeMode();
  }

  final LocalStorageRepository _localStorageRepository;

  /// Loads the user's preferred [ThemeMode] from [LocalStorageRepository].
  Future<void> loadThemeMode() async {
    final themeMode = await _localStorageRepository.loadThemeMode();
    // Dot not perform any work if new and old ThemeMode are identical
    if (themeMode == state) return;
    state = themeMode ?? ThemeMode.system;
  }

  /// Change and persist the [ThemeMode] based on the user's selection.
  Future<void> changeThemeMode(ThemeMode? themeMode) async {
    if (themeMode == null) return;
    // Dot not perform any work if new and old ThemeMode are identical
    if (themeMode == state) return;
    // Otherwise, store the new theme mode in memory
    state = themeMode;
    // Persists the user's preferred ThemeMode to local storage.
    await _localStorageRepository.saveThemeMode(themeMode);
  }
}

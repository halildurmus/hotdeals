import 'dart:io';

import 'package:flutter/material.dart' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/local_storage_repository.dart';

final localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale>(
        (ref) => LocaleController(ref.read),
        name: 'LocaleController');

class LocaleController extends StateNotifier<Locale> {
  LocaleController(Reader read)
      : _localStorageRepository = read(localStorageRepositoryProvider),
        super(const Locale('en')) {
    loadLocale();
  }

  final LocalStorageRepository _localStorageRepository;

  /// Loads the user's preferred [Locale] from [LocalStorageRepository].
  ///
  /// If the preferred [Locale] is not found then [Platform.localeName] is used.
  Future<void> loadLocale() async {
    final locale = await _localStorageRepository.loadLocale();
    // Dot not perform any work if new and old Locale are identical
    if (locale == state) return;
    state = locale ?? Locale(Platform.localeName.split('_')[0]);
  }

  /// Change and persist the [Locale] based on the user's selection.
  Future<void> changeLocale(Locale? locale) async {
    if (locale == null) return;
    // Dot not perform any work if new and old Locale are identical
    if (locale == state) return;
    // Otherwise, store the new Locale in memory
    state = locale;
    // Persists the user's preferred Locale to local storage.
    await _localStorageRepository.saveLocale(locale);
  }
}

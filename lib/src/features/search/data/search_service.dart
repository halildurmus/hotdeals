import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/hotdeals_api.dart';
import '../../../core/hotdeals_repository.dart';
import '../../../core/local_storage_repository.dart';
import '../domain/search_suggestion.dart';

final searchServiceProvider = Provider<SearchService>(
    (ref) => SearchService(ref.read),
    name: 'SearchServiceProvider');

/// A class used for search functionality.
///
/// This service persist the recent searches history locally, using the
/// [shared_preferences] package.
class SearchService {
  SearchService(Reader read)
      : _hotdealsRepository = read(hotdealsRepositoryProvider),
        _localStorageRepository = read(localStorageRepositoryProvider);

  final HotdealsApi _hotdealsRepository;
  final LocalStorageRepository _localStorageRepository;

  Future<SearchSuggestion> getSuggestions(String query) =>
      _hotdealsRepository.getDealSuggestions(query: query);

  /// Loads the user's search history from [SharedPreferences].
  Future<List<String>> getRecentSearches() async =>
      await _localStorageRepository.loadRecentSearchHistory() ?? [];

  /// Persists the query to local storage.
  Future<void> saveQuery(String query) async {
    final recentSearchHistory = await getRecentSearches();
    if (recentSearchHistory.contains(query)) return;
    recentSearchHistory.insert(0, query);
    // We only show the last 5 recent searches to the user, so remove the last
    // one if the list is longer than 5
    if (recentSearchHistory.length > 5) {
      recentSearchHistory.removeLast();
    }

    await _localStorageRepository.saveRecentSearchHistory(recentSearchHistory);
  }

  /// Deletes the query from local storage.
  Future<void> deleteQuery(String query) async {
    final recentSearchHistory = await getRecentSearches();
    if (!recentSearchHistory.contains(query)) return;
    recentSearchHistory.remove(query);
    await _localStorageRepository.saveRecentSearchHistory(recentSearchHistory);
  }
}

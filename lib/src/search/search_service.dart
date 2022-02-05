import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_repository.dart';
import 'search_suggestion.dart';

/// A class used for search functionality.
///
/// This service persist the recent searches history locally, using the
/// [shared_preferences] package.
class SearchService {
  SearchService(this._prefs);

  final SharedPreferences _prefs;
  static const String _recentSearchesKey = 'recent-searches';

  Future<SearchSuggestion> getSuggestions(String query) async =>
      GetIt.I.get<APIRepository>().getDealSuggestions(query: query);

  /// Loads the user's search history from [SharedPreferences].
  List<String> getRecentSearches() =>
      _prefs.getStringList(_recentSearchesKey) ?? [];

  /// Persists the query to local storage.
  void saveQuery(String query) {
    final recentSearches = getRecentSearches();
    if (!recentSearches.contains(query)) {
      recentSearches.insert(0, query);
    }
    // We only show the user last 5 recent searches, so if it is greater than 5,
    // remove the last search
    if (recentSearches.length > 5) {
      recentSearches.removeLast();
    }

    _prefs.setStringList(_recentSearchesKey, recentSearches);
  }

  /// Deletes the query from local storage.
  void deleteQuery(String query) {
    final recentSearches = getRecentSearches();
    if (recentSearches.contains(query)) {
      recentSearches.remove(query);
      _prefs.setStringList(_recentSearchesKey, recentSearches);
    }
  }
}

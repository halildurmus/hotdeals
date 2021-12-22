import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../search/suggestion_response.dart';
import '../services/spring_service.dart';

/// A class used for search functionality.
///
/// This service persist the recent searches history locally, using the
/// [shared_preferences] package.
class SearchService {
  SearchService(this._prefs);

  final SharedPreferences _prefs;
  static const String _recentSearchesKey = 'recent-searches';

  Future<SuggestionResponse> getSuggestions(String query) async =>
      GetIt.I.get<SpringService>().getDealSuggestions(query: query);

  /// Loads the user's search history from [SharedPreferences].
  List<String> recentSearches() =>
      _prefs.getStringList(_recentSearchesKey) ?? [];

  /// Persists the query to local storage.
  void saveQuery(String query) {
    final _recentSearches = recentSearches();
    if (!_recentSearches.contains(query)) {
      _recentSearches.insert(0, query);
    }
    if (_recentSearches.length > 5) {
      _recentSearches.removeLast();
    }

    _prefs.setStringList(_recentSearchesKey, _recentSearches);
  }

  /// Removes the query from local storage.
  void removeQuery(String query) {
    final _recentSearches = recentSearches();
    if (_recentSearches.contains(query)) {
      _recentSearches.remove(query);
      _prefs.setStringList(_recentSearchesKey, _recentSearches);
    }
  }
}

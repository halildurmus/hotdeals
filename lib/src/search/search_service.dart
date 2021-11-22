import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/spring_service.dart';
import 'search_hit.dart';

/// A class used for search functionality.
///
/// This service persist the recent searches history locally, using the
/// [shared_preferences] package.
class SearchService {
  SearchService(this._prefs);

  final SharedPreferences _prefs;
  static const String _recentSearchesKey = 'recent-searches';

  Future<List<SearchHit>> searchDeals(String keyword) async =>
      await GetIt.I.get<SpringService>().searchDeals(keyword: keyword);

  /// Loads the user's search history from [SharedPreferences].
  List<String> recentSearches() =>
      _prefs.getStringList(_recentSearchesKey) ?? [];

  /// Persists the keyword to local storage.
  void saveKeyword(String keyword) {
    final _recentSearches = recentSearches();
    if (!_recentSearches.contains(keyword)) {
      _recentSearches.insert(0, keyword);
    }
    if (_recentSearches.length > 5) {
      _recentSearches.removeLast();
    }

    _prefs.setStringList(_recentSearchesKey, _recentSearches);
  }

  /// Removes the keyword from local storage.
  void removeKeyword(String keyword) {
    final _recentSearches = recentSearches();
    if (_recentSearches.contains(keyword)) {
      _recentSearches.remove(keyword);
      _prefs.setStringList(_recentSearchesKey, _recentSearches);
    }
  }
}

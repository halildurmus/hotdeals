import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loggy/loggy.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import '../data/search_service.dart';
import '../domain/search_data.dart';
import '../domain/search_params.dart';

final searchControllerProvider =
    StateNotifierProvider.autoDispose<SearchController, SearchData>((ref) {
  final floatingSearchBarController = FloatingSearchBarController();
  final controller = SearchController(ref.read, floatingSearchBarController);
  ref.onDispose(floatingSearchBarController.dispose);
  return controller;
}, name: 'SearchControllerProvider');

class SearchController extends StateNotifier<SearchData> with NetworkLoggy {
  SearchController(Reader read, FloatingSearchBarController controller)
      : _searchService = read(searchServiceProvider),
        super(
          SearchData(
            floatingSearchBarController: controller,
            isSearchErrorOccurred: false,
            isSearchModeActive: false,
            progress: false,
            recentSearches: const [],
            searchParams: SearchParams(),
            suggestions: const [],
          ),
        ) {
    _fetchRecentSearches();
  }

  final SearchService _searchService;

  static const int minQueryLength = 3;

  void _fetchRecentSearches() async {
    final recentSearches = await _searchService.getRecentSearches();
    state = state.copyWith(recentSearches: recentSearches);
  }

  Future<void> fetchSuggestions(String query) async {
    state = state.copyWith(progress: true);
    try {
      final suggestionResponse = await _searchService.getSuggestions(query);
      state = state.copyWith(
        isSearchErrorOccurred: false,
        progress: false,
        suggestions: suggestionResponse.suggestions,
      );
    } on Exception {
      state = state.copyWith(isSearchErrorOccurred: true, progress: false);
    }
  }

  void onFocusChanged(bool value) {
    final isQueryEmpty = state.searchParams.query.isEmpty &&
        state.floatingSearchBarController.query.isEmpty;
    if (value) {
      state.floatingSearchBarController.query = state.searchParams.query;
    } else if (!value && state.searchParams.query.isEmpty || isQueryEmpty) {
      onSearchModeChanged(false);
    }
  }

  void onSearchModeChanged(bool value) {
    state = state.copyWith(
      isSearchModeActive: value,
      searchParams: value ? state.searchParams : SearchParams(),
    );
  }

  void onSubmitted(String query) {
    if (query.isNotEmpty) {
      onQueryTap(query);
    }
  }

  void onQueryChanged(String query) {
    if (query.length < minQueryLength) return;
    fetchSuggestions(query);
  }

  void onQueryTap(String query) async {
    state =
        state.copyWith(searchParams: state.searchParams.copyWith(query: query));
    state.floatingSearchBarController.close();
    await _searchService.saveQuery(query);
    _fetchRecentSearches();
  }

  Widget buildError(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.error),
      title: Text(AppLocalizations.of(context)!.anErrorOccurred),
    );
  }

  Widget buildRecentSearches(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: state.recentSearches
          .map(
            (query) => ListTile(
              onTap: () => onQueryTap(query),
              leading: const Icon(Icons.history),
              title: Text(
                query,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                onPressed: () async {
                  await _searchService.deleteQuery(query);
                  _fetchRecentSearches();
                },
                icon: const Icon(Icons.clear),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget buildSuggestions(BuildContext context) {
    if (state.suggestions.isEmpty) {
      return buildListTile(context, state.floatingSearchBarController.query);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: state.suggestions
          .map((query) => buildListTile(context, query))
          .toList(),
    );
  }

  Widget buildListTile(BuildContext context, String query) {
    return ListTile(
      onTap: () => onQueryTap(query),
      leading: const Icon(Icons.search),
      title: Text(
        query,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

import 'package:flutter/widgets.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import 'search_params.dart';

@immutable
class SearchData {
  const SearchData({
    required this.floatingSearchBarController,
    required this.isSearchErrorOccurred,
    required this.isSearchModeActive,
    required this.progress,
    required this.recentSearches,
    required this.suggestions,
    required this.searchParams,
  });

  final FloatingSearchBarController floatingSearchBarController;
  final bool isSearchErrorOccurred;
  final bool isSearchModeActive;
  final bool progress;
  final List<String> recentSearches;
  final List<String> suggestions;
  final SearchParams searchParams;

  SearchData copyWith({
    FloatingSearchBarController? floatingSearchBarController,
    bool? isSearchErrorOccurred,
    bool? isSearchModeActive,
    bool? progress,
    List<String>? recentSearches,
    List<String>? suggestions,
    SearchParams? searchParams,
  }) =>
      SearchData(
        floatingSearchBarController:
            floatingSearchBarController ?? this.floatingSearchBarController,
        isSearchErrorOccurred:
            isSearchErrorOccurred ?? this.isSearchErrorOccurred,
        isSearchModeActive: isSearchModeActive ?? this.isSearchModeActive,
        progress: progress ?? this.progress,
        recentSearches: recentSearches ?? this.recentSearches,
        suggestions: suggestions ?? this.suggestions,
        searchParams: searchParams ?? this.searchParams,
      );
}

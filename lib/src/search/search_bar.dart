import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import '../services/spring_service.dart';
import 'search_hit.dart';
import 'search_results.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({
    Key? key,
    required this.controller,
    required this.onSearchModeChanged,
  }) : super(key: key);

  final FloatingSearchBarController controller;
  final ValueChanged<bool> onSearchModeChanged;

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  bool searchError = false;
  bool searchInProgress = false;
  final List<String> searchResults = [];
  String selectedKeyword = '';

  Future<void> searchDeals(String keyword) async {
    searchResults.clear();
    setState(() {
      searchInProgress = true;
    });

    late final List<SearchHit> searchHits;
    try {
      searchHits =
          await GetIt.I.get<SpringService>().searchDeals(keyword: keyword);
    } on Exception {
      setState(() {
        searchError = true;
        searchInProgress = false;
      });
      return;
    }

    for (SearchHit e in searchHits) {
      searchResults.add(e.content.title);
    }

    setState(() {
      searchError = false;
      searchInProgress = false;
    });
  }

  Widget buildSearchError() {
    return ListTile(
      title: Text(AppLocalizations.of(context)!.anErrorOccurred),
    );
  }

  void onKeywordTap(String keyword) {
    setState(() {
      selectedKeyword = keyword;
    });
    widget.controller.close();
  }

  Widget buildRecentSearches() {
    // TODO(halildurmus): Implement this with the shared_preferences or sqflite.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => ListTile(
          onTap: () => onKeywordTap('Item$index'),
          leading: const Icon(Icons.history),
          title: Text('Item$index'),
          trailing: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.clear),
          ),
        ),
      ),
    );
  }

  Widget buildNoSuggestions(String keyword) {
    return ListTile(
      onTap: () => onKeywordTap(keyword),
      leading: const Icon(Icons.search),
      title: Text(keyword),
    );
  }

  Widget buildSuggestions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: searchResults
          .map(
            (keyword) => ListTile(
              onTap: () => onKeywordTap(keyword),
              leading: const Icon(Icons.search),
              title: Text(keyword),
            ),
          )
          .toList(),
    );
  }

  List<Widget> buildActions() => [FloatingSearchBarAction.searchToClear()];

  Widget buildSearchBarContent() {
    Widget? child;
    if (!searchInProgress && widget.controller.query.isEmpty) {
      child = buildRecentSearches();
    } else if (searchError) {
      child = buildSearchError();
    } else if (!searchInProgress && searchResults.isEmpty) {
      child = buildNoSuggestions(widget.controller.query);
    } else if (!searchInProgress && searchResults.isNotEmpty) {
      child = buildSuggestions();
    }

    return Material(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: child,
    );
  }

  List<Widget> buildLeadingActions() => [
        FloatingSearchBarAction.icon(
          onTap: () => setState(() => widget.onSearchModeChanged(false)),
          icon: const Icon(Icons.arrow_back),
          showIfOpened: true,
        ),
        FloatingSearchBarAction.icon(
          onTap: () {},
          icon: const Icon(Icons.search),
          showIfClosed: false,
        )
      ];

  void onFocusChanged(bool value) {
    if (value) {
      widget.controller.query = selectedKeyword;
    } else if (!value && selectedKeyword.isEmpty) {
      setState(() {
        widget.onSearchModeChanged(false);
      });
    }
  }

  void onSubmitted(String query) {
    if (query.isNotEmpty) {
      onKeywordTap(query);
    }
  }

  void onQueryChanged(String query) =>
      query.isEmpty ? setState(() {}) : searchDeals(query);

  Widget buildFloatingSearchBar() {
    final portraitMode =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      actions: buildActions(),
      automaticallyImplyBackButton: false,
      axisAlignment: portraitMode ? 0 : -1,
      body: FloatingSearchBarScrollNotifier(
        child: SearchResults(
          keyword: selectedKeyword,
        ),
      ),
      builder: (_, __) => buildSearchBarContent(),
      controller: widget.controller,
      debounceDelay: const Duration(milliseconds: 500),
      hint: AppLocalizations.of(context)!.search,
      leadingActions: buildLeadingActions(),
      onFocusChanged: onFocusChanged,
      onSubmitted: onSubmitted,
      onQueryChanged: onQueryChanged,
      openAxisAlignment: 0,
      physics: const BouncingScrollPhysics(),
      progress: searchInProgress,
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      title: Text(
        selectedKeyword.isNotEmpty ? selectedKeyword : 'hotdeals',
        style: Theme.of(context).textTheme.headline6,
      ),
      transition: CircularFloatingSearchBarTransition(),
      transitionCurve: Curves.easeInOut,
      transitionDuration: const Duration(milliseconds: 200),
      width: portraitMode ? 600 : 500,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        inputDecorationTheme:
            theme.inputDecorationTheme.copyWith(fillColor: Colors.transparent),
      ),
      child: buildFloatingSearchBar(),
    );
  }
}

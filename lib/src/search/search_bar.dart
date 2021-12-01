import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import '../utils/localization_util.dart';
import 'search_hit.dart';
import 'search_results.dart';
import 'search_service.dart';

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
  final searchService = GetIt.I.get<SearchService>();
  bool searchError = false;
  final List<String> searchResults = [];
  String selectedQuery = '';

  Future<void> searchDeals(String query) async {
    searchResults.clear();
    try {
      final searchHits = await searchService.searchDeals(query);
      for (SearchHit s in searchHits) {
        searchResults.add(s.content.title);
      }
      setState(() => searchError = false);
    } on Exception {
      setState(() => searchError = true);
    }
  }

  Widget buildSearchError() {
    return ListTile(
      title: Text(l(context).anErrorOccurred),
    );
  }

  void onQueryTap(String query) {
    setState(() => selectedQuery = query);
    widget.controller.close();
    searchService.saveQuery(query);
  }

  Widget buildRecentSearches() {
    void onIconButtonPressed(String query) =>
        setState(() => searchService.removeQuery(query));

    final recentSearches = searchService.recentSearches();
    if (recentSearches.isEmpty) return const SizedBox();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: recentSearches
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
                onPressed: () => onIconButtonPressed(query),
                icon: const Icon(Icons.clear),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget buildListTile(String query) {
    return ListTile(
      onTap: () => onQueryTap(query),
      leading: const Icon(Icons.search),
      title: Text(query),
    );
  }

  Widget buildSuggestions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: searchResults
          .map(
            (query) => ListTile(
              onTap: () => onQueryTap(query),
              leading: const Icon(Icons.search),
              title: Text(query),
            ),
          )
          .toList(),
    );
  }

  List<Widget> buildActions() => [FloatingSearchBarAction.searchToClear()];

  Widget buildSearchBarContent() {
    final query = widget.controller.query;
    late Widget child;
    if (query.isEmpty) {
      child = buildRecentSearches();
    } else if (searchError) {
      child = buildSearchError();
    } else if (query.length >= 3 && searchResults.isNotEmpty) {
      child = buildSuggestions();
    } else {
      child = buildListTile(query);
    }

    return Material(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
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
      widget.controller.query = selectedQuery;
    } else if (!value && selectedQuery.isEmpty ||
        (selectedQuery.isEmpty && widget.controller.query.isEmpty)) {
      setState(() => widget.onSearchModeChanged(false));
    }
  }

  void onSubmitted(String query) {
    if (query.isNotEmpty) {
      onQueryTap(query);
    }
  }

  void onQueryChanged(String query) =>
      query.length < 3 ? setState(() {}) : searchDeals(query);

  Widget buildFloatingSearchBar() {
    final portraitMode =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      actions: buildActions(),
      automaticallyImplyBackButton: false,
      axisAlignment: portraitMode ? 0 : -1,
      body: FloatingSearchBarScrollNotifier(
        child: SearchResults(
          query: selectedQuery,
          onSearchModeChanged: widget.onSearchModeChanged,
        ),
      ),
      builder: (_, __) => buildSearchBarContent(),
      controller: widget.controller,
      debounceDelay: const Duration(milliseconds: 500),
      hint: l(context).search,
      leadingActions: buildLeadingActions(),
      onFocusChanged: onFocusChanged,
      onSubmitted: onSubmitted,
      onQueryChanged: onQueryChanged,
      openAxisAlignment: 0,
      physics: const BouncingScrollPhysics(),
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      title: Text(
        selectedQuery.isNotEmpty ? selectedQuery : 'hotdeals',
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

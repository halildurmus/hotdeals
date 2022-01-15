import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import '../utils/localization_util.dart';
import 'search_params.dart';
import 'search_results.dart';
import 'search_service.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({
    required this.controller,
    required this.onSearchModeChanged,
    Key? key,
  }) : super(key: key);

  final FloatingSearchBarController controller;
  final ValueChanged<bool> onSearchModeChanged;

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final searchService = GetIt.I.get<SearchService>();
  bool searchError = false;
  final _suggestions = <String>[];
  SearchParams searchParams = SearchParams();

  Future<void> getSuggestions(String query) async {
    _suggestions.clear();
    try {
      final suggestionResponse = await searchService.getSuggestions(query);
      if (suggestionResponse.suggestions.isNotEmpty) {
        _suggestions.addAll(suggestionResponse.suggestions);
      }
      setState(() => searchError = false);
    } on Exception {
      setState(() => searchError = true);
    }
  }

  Widget buildError() => ListTile(
        title: Text(l(context).anErrorOccurred),
      );

  void onQueryTap(String query) {
    searchParams = searchParams.copyWith(query: query);
    setState(() {});
    widget.controller.close();
    searchService.saveQuery(query);
  }

  Widget buildRecentSearches() {
    void onIconButtonPressed(String query) =>
        setState(() => searchService.deleteQuery(query));

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

  Widget buildListTile(String query) => ListTile(
        onTap: () => onQueryTap(query),
        leading: const Icon(Icons.search),
        title: Text(query),
      );

  Widget buildSuggestions() => Column(
        mainAxisSize: MainAxisSize.min,
        children: _suggestions
            .map(
              (query) => ListTile(
                onTap: () => onQueryTap(query),
                leading: const Icon(Icons.search),
                title: Text(query),
              ),
            )
            .toList(),
      );

  List<Widget> buildActions() => [FloatingSearchBarAction.searchToClear()];

  Widget buildSearchBarContent() {
    final query = widget.controller.query;
    late Widget child;
    if (query.isEmpty) {
      child = buildRecentSearches();
    } else if (searchError) {
      child = buildError();
    } else if (query.length >= 3 && _suggestions.isNotEmpty) {
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
      widget.controller.query = searchParams.query;
    } else if (!value && searchParams.query.isEmpty ||
        (searchParams.query.isEmpty && widget.controller.query.isEmpty)) {
      setState(() => widget.onSearchModeChanged(false));
    }
  }

  void onSubmitted(String query) {
    if (query.isNotEmpty) {
      onQueryTap(query);
    }
  }

  void onQueryChanged(String query) =>
      query.length < 3 ? setState(() {}) : getSuggestions(query);

  Widget buildFloatingSearchBar() {
    final portraitMode =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      actions: buildActions(),
      automaticallyImplyBackButton: false,
      axisAlignment: portraitMode ? 0 : -1,
      body: FloatingSearchBarScrollNotifier(
        child: WillPopScope(
          onWillPop: () {
            widget.onSearchModeChanged(false);

            return Future<bool>.value(false);
          },
          child: SearchResults(searchParams: searchParams),
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
        searchParams.query.isNotEmpty ? searchParams.query : 'hotdeals',
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

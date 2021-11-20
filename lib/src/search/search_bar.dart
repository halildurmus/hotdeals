import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import '../services/spring_service.dart';
import '../utils/navigation_util.dart';
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

  Future<void> searchDeals(String keyword) async {
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

    searchResults.clear();
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

  Widget buildPlaceHolder() {
    return const ListTile(title: Text('Placeholder'));
  }

  Widget buildNoResults() {
    return ListTile(
      title: Text(AppLocalizations.of(context)!.noResults),
    );
  }

  List<Widget> buildActions() => [
        FloatingSearchBarAction.searchToClear(showIfClosed: false),
      ];

  Widget buildSearchResults() {
    return ListView.separated(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: math.min(searchResults.length, 5),
      itemBuilder: (context, index) {
        final keyword = searchResults.elementAt(index);

        return ListTile(
          onTap: () => NavigationUtil.navigate(
            context,
            SearchResults(keyword: keyword),
          ),
          leading: const Icon(Icons.search),
          title: Text(keyword),
        );
      },
      separatorBuilder: (context, index) => const Divider(height: 0),
    );
  }

  Widget buildSearchBarBuilder() {
    // TODO(halildurmus): Add support for displaying recent searches.
    return Material(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: searchError
          ? buildSearchError()
          : widget.controller.query.isEmpty
              ? buildPlaceHolder()
              : searchResults.isEmpty
                  ? buildNoResults()
                  : buildSearchResults(),
    );
  }

  List<Widget> buildLeadingActions() => [
        FloatingSearchBarAction.icon(
          onTap: () => setState(() => widget.onSearchModeChanged(false)),
          icon: const Icon(Icons.arrow_back),
          showIfClosed: false,
          showIfOpened: true,
        ),
        FloatingSearchBarAction.icon(
          onTap: () {},
          icon: const Icon(Icons.search),
        )
      ];

  void onFocusChanged(bool value) {
    if (!value) {
      setState(() {
        widget.onSearchModeChanged(false);
      });
    }
  }

  void onSubmitted(String query) {
    if (query.isNotEmpty) {
      NavigationUtil.navigate(context, SearchResults(keyword: query));
    }
  }

  void onQueryChanged(String query) {
    if (query.isNotEmpty) {
      searchDeals(query);
    }
  }

  Widget buildFloatingSearchBar() {
    final portraitMode =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      actions: buildActions(),
      automaticallyImplyBackButton: false,
      axisAlignment: portraitMode ? 0 : -1,
      builder: (_, __) => buildSearchBarBuilder(),
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

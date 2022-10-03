import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import '../../../common_widgets/error_indicator.dart';
import '../../../helpers/context_extensions.dart';
import 'search_controller.dart';
import 'search_results_screen.dart';

class SearchBar extends ConsumerStatefulWidget {
  const SearchBar({super.key});

  @override
  ConsumerState<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<SearchBar> {
  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(searchControllerProvider);
    return Theme(
      data: context.t.copyWith(
        inputDecorationTheme: context.t.inputDecorationTheme
            .copyWith(fillColor: Colors.transparent),
      ),
      child: FloatingSearchBar(
        automaticallyImplyBackButton: false,
        progress: controller.progress,
        body: FloatingSearchBarScrollNotifier(
          child: WillPopScope(
            onWillPop: () {
              ref
                  .read(searchControllerProvider.notifier)
                  .onSearchModeChanged(false);
              return Future<bool>.value(false);
            },
            child: controller.searchParams.query.isNotEmpty
                ? SearchResultsScreen(searchParams: controller.searchParams)
                : ErrorIndicator(
                    icon: Icons.search,
                    title: context.l.startSearching,
                  ),
          ),
        ),
        builder: (_, __) {
          final query = controller.floatingSearchBarController.query;
          final Widget child;
          if (query.isEmpty) {
            child = ref
                .read(searchControllerProvider.notifier)
                .buildRecentSearches(context);
          } else if (controller.isSearchErrorOccurred) {
            child =
                ref.read(searchControllerProvider.notifier).buildError(context);
          } else if (query.length >= SearchController.minQueryLength) {
            child = ref
                .read(searchControllerProvider.notifier)
                .buildSuggestions(context);
          } else {
            child = ref
                .read(searchControllerProvider.notifier)
                .buildListTile(context, query);
          }

          return Material(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: child,
          );
        },
        controller: controller.floatingSearchBarController,
        debounceDelay: const Duration(milliseconds: 500),
        hint: context.l.search,
        leadingActions: [
          FloatingSearchBarAction.icon(
            onTap: () => ref
                .read(searchControllerProvider.notifier)
                .onSearchModeChanged(false),
            icon: const Icon(Icons.arrow_back),
            showIfOpened: true,
          ),
          FloatingSearchBarAction.icon(
            onTap: () {},
            icon: const Icon(Icons.search),
            showIfClosed: false,
          )
        ],
        onFocusChanged:
            ref.read(searchControllerProvider.notifier).onFocusChanged,
        onSubmitted: ref.read(searchControllerProvider.notifier).onSubmitted,
        onQueryChanged: (query) {
          if (query.length < 3) {
            setState(() {});
          }
          ref.read(searchControllerProvider.notifier).onQueryChanged(query);
        },
        title: controller.searchParams.query.isNotEmpty
            ? Text(
                controller.searchParams.query,
                style: context.textTheme.titleLarge,
              )
            : null,
      ),
    );
  }
}

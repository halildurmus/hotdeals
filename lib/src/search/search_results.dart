import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart'
    show PagingController;
import 'package:material_floating_search_bar/material_floating_search_bar.dart'
    show FloatingSearchBar;

import '../models/deal.dart';
import '../services/spring_service.dart';
import '../widgets/deal_paged_listview.dart';
import '../widgets/error_indicator.dart';

class SearchResults extends StatefulWidget {
  const SearchResults({Key? key, required this.query}) : super(key: key);

  final String query;

  @override
  State<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  late PagingController<int, Deal> _pagingController;

  @override
  void initState() {
    _pagingController = PagingController<int, Deal>(firstPageKey: 0);
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SearchResults oldWidget) {
    if (oldWidget.query != widget.query) {
      _pagingController.refresh();
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<List<Deal>?> _dealFuture(int page, int size) =>
      GetIt.I.get<SpringService>().getDealsByKeyword(
            keyword: widget.query,
            page: page,
            size: size,
          );

  Widget buildNoDealsFound(BuildContext context) {
    return ErrorIndicator(
      icon: Icons.local_offer,
      title: AppLocalizations.of(context)!.couldNotFindAnyDeal,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.query.isEmpty) {
      return const ErrorIndicator(
        icon: Icons.search,
        title: 'Start searching',
      );
    }

    final fsb = FloatingSearchBar.of(context)!;

    return Padding(
      padding: EdgeInsets.only(
        top: fsb.widget.height + MediaQuery.of(context).viewPadding.top,
      ),
      child: DealPagedListView(
        dealFuture: _dealFuture,
        noDealsFound: buildNoDealsFound(context),
        pagingController: _pagingController,
      ),
    );
  }
}

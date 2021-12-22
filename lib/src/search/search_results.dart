import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart'
    show PagingController;
import 'package:material_floating_search_bar/material_floating_search_bar.dart'
    show FloatingSearchBar;

import '../models/deal.dart';
import '../search/search_response.dart';
import '../services/spring_service.dart';
import '../utils/localization_util.dart';
import '../widgets/deal_paged_listview.dart';
import '../widgets/error_indicator.dart';
import 'search_params.dart';

class SearchResults extends StatefulWidget {
  const SearchResults({Key? key, required this.searchParams}) : super(key: key);

  final SearchParams searchParams;

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
    if (oldWidget.searchParams != widget.searchParams) {
      _pagingController.refresh();
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<SearchResponse> _searchResultsFuture(int page, int size) => GetIt.I
      .get<SpringService>()
      .searchDeals(searchParams: widget.searchParams);

  Widget buildNoDealsFound(BuildContext context) => ErrorIndicator(
        icon: Icons.local_offer,
        title: l(context).couldNotFindAnyDeal,
      );

  @override
  Widget build(BuildContext context) {
    if (widget.searchParams.query.isEmpty) {
      return ErrorIndicator(
        icon: Icons.search,
        title: l(context).startSearching,
      );
    }

    final fsb = FloatingSearchBar.of(context)!;

    return Padding(
      padding: EdgeInsets.only(
        top: fsb.widget.height + MediaQuery.of(context).viewPadding.top,
      ),
      child: DealPagedListView.withFilterBar(
        noDealsFound: buildNoDealsFound(context),
        pagingController: _pagingController,
        searchResultsFuture: _searchResultsFuture,
        searchParams: widget.searchParams,
      ),
    );
  }
}

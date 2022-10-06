import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart'
    show PagingController;
import 'package:material_floating_search_bar/material_floating_search_bar.dart'
    show FloatingSearchBar;

import '../../../common_widgets/error_indicator.dart';
import '../../../core/hotdeals_repository.dart';
import '../../../helpers/context_extensions.dart';
import '../../deal/domain/deal.dart';
import '../../deal/presentation/widgets/deal_paged_list_view.dart';
import '../domain/search_params.dart';

class SearchResultsScreen extends ConsumerStatefulWidget {
  const SearchResultsScreen({required this.searchParams, super.key});

  final SearchParams searchParams;

  @override
  ConsumerState<SearchResultsScreen> createState() => _SearchResultsState();
}

class _SearchResultsState extends ConsumerState<SearchResultsScreen> {
  late PagingController<int, Deal> _pagingController;

  @override
  void initState() {
    _pagingController = PagingController<int, Deal>(firstPageKey: 0);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SearchResultsScreen oldWidget) {
    if (oldWidget.searchParams != widget.searchParams) {
      _pagingController.refresh();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fsb = FloatingSearchBar.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        top: fsb.widget.height + context.mq.viewPadding.top,
      ),
      child: DealPagedListView.withFilterBar(
        noDealsFound: ErrorIndicator(
          icon: Icons.local_offer,
          title: context.l.couldNotFindAnyDeal,
        ),
        pagingController: _pagingController,
        searchParams: widget.searchParams,
        searchResultsFuture: (int page, int size) => ref
            .read(hotdealsRepositoryProvider)
            .searchDeals(searchParams: widget.searchParams),
      ),
    );
  }
}

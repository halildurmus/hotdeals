import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart'
    show PagingController;

import '../../../common_widgets/error_indicator.dart';
import '../../../core/hotdeals_repository.dart';
import '../../../helpers/context_extensions.dart';
import '../../search/presentation/search_bar.dart';
import '../../search/presentation/search_controller.dart';
import '../domain/deal.dart';
import 'widgets/deal_paged_list_view.dart';
import 'widgets/deals_screen_appbar.dart';

class DealsScreen extends ConsumerStatefulWidget {
  const DealsScreen({super.key});

  @override
  ConsumerState<DealsScreen> createState() => _DealsState();
}

class _DealsState extends ConsumerState<DealsScreen>
    with SingleTickerProviderStateMixin {
  late final PagingController<int, Deal> _pagingControllerLatest;
  late final PagingController<int, Deal> _pagingControllerMostLiked;
  late final TabController tabController;

  @override
  void initState() {
    _pagingControllerLatest = PagingController<int, Deal>(firstPageKey: 0);
    _pagingControllerMostLiked = PagingController<int, Deal>(firstPageKey: 0);
    tabController = TabController(vsync: this, length: 2);
    super.initState();
  }

  @override
  void dispose() {
    _pagingControllerLatest.dispose();
    _pagingControllerMostLiked.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSearchModeActive = ref.watch(
        searchControllerProvider.select((value) => value.isSearchModeActive));
    return Scaffold(
      appBar: isSearchModeActive
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: DealsScreenAppBar(tabController: tabController),
            ),
      body: isSearchModeActive
          ? const SearchBar()
          : TabBarView(
              controller: tabController,
              children: [
                DealPagedListView(
                  dealsFuture: (int page, int size) => ref
                      .read(hotdealsRepositoryProvider)
                      .getLatestDeals(page: page, size: size),
                  pagingController: _pagingControllerLatest,
                  noDealsFound: ErrorIndicator(
                    icon: Icons.local_offer,
                    title: context.l.couldNotFindAnyDeal,
                  ),
                ),
                DealPagedListView(
                  dealsFuture: (int page, int size) => ref
                      .read(hotdealsRepositoryProvider)
                      .getMostLikedDeals(page: page, size: size),
                  pagingController: _pagingControllerMostLiked,
                  noDealsFound: ErrorIndicator(
                    icon: Icons.local_offer,
                    title: context.l.couldNotFindAnyDeal,
                  ),
                ),
              ],
            ),
      resizeToAvoidBottomInset: false,
    );
  }
}

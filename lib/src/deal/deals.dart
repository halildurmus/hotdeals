import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart'
    show PagingController;
import 'package:material_floating_search_bar/material_floating_search_bar.dart'
    show FloatingSearchBarController;
import 'package:provider/provider.dart';

import '../models/deal.dart';
import '../models/my_user.dart';
import '../models/user_controller.dart';
import '../search/search_bar.dart';
import '../services/spring_service.dart';
import '../utils/localization_util.dart';
import '../utils/navigation_util.dart';
import '../widgets/deal_paged_listview.dart';
import '../widgets/error_indicator.dart';
import 'post_deal.dart';

class Deals extends StatefulWidget {
  const Deals({Key? key}) : super(key: key);

  @override
  _DealsState createState() => _DealsState();
}

class _DealsState extends State<Deals> with SingleTickerProviderStateMixin {
  late PagingController<int, Deal> _pagingController;
  bool _searchMode = false;
  late final FloatingSearchBarController _searchBarController;
  late final TabController tabController;

  @override
  void initState() {
    _pagingController = PagingController<int, Deal>(firstPageKey: 0);
    _searchBarController = FloatingSearchBarController();
    tabController = TabController(vsync: this, length: 1);
    super.initState();
  }

  @override
  void dispose() {
    _searchBarController.dispose();
    _pagingController.dispose();
    super.dispose();
  }

  Future<List<Deal>> _dealFuture(int page, int size) =>
      GetIt.I.get<SpringService>().getLatestDeals(page: page, size: size);

  Widget buildNoDealsFound(BuildContext context) {
    return ErrorIndicator(
      icon: Icons.local_offer,
      title: l(context).couldNotFindAnyDeal,
    );
  }

  Widget _buildSearchBar() {
    return SearchBar(
      controller: _searchBarController,
      onSearchModeChanged: (bool value) => setState(() => _searchMode = value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MyUser? user = Provider.of<UserController>(context).user;

    Widget _buildTabBarView() {
      return TabBarView(
        controller: tabController,
        children: [
          DealPagedListView(
            dealsFuture: _dealFuture,
            pagingController: _pagingController,
            noDealsFound: buildNoDealsFound(context),
          ),
        ],
      );
    }

    PreferredSizeWidget _buildAppBar() {
      List<Widget> _buildActions() {
        return [
          IconButton(
            onPressed: () {
              setState(() {
                _searchMode = true;
              });
              WidgetsBinding.instance!.addPostFrameCallback(
                  (timeStamp) => _searchBarController.open());
            },
            icon: const Icon(Icons.search),
          ),
          if (user != null)
            IconButton(
              onPressed: () =>
                  NavigationUtil.navigate(context, const PostDeal())
                      .then((_) => _pagingController.refresh()),
              icon: const Icon(Icons.add_circle),
            ),
        ];
      }

      return AppBar(
        title: Text(l(context).appTitle),
        actions: _buildActions(),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight * 1),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 2),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                controller: tabController,
                isScrollable: true,
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                tabs: [Tab(text: l(context).latest)],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _searchMode ? null : _buildAppBar(),
      body: _searchMode ? _buildSearchBar() : _buildTabBarView(),
      resizeToAvoidBottomInset: false,
    );
  }
}

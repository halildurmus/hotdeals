import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart'
    show PagingController;
import 'package:material_floating_search_bar/material_floating_search_bar.dart'
    show FloatingSearchBarController;
import 'package:provider/provider.dart';

import '../models/deal.dart';
import '../models/deal_sortby.dart';
import '../models/my_user.dart';
import '../models/user_controller.dart';
import '../search/search_bar.dart';
import '../services/spring_service.dart';
import '../utils/navigation_util.dart';
import '../widgets/deal_paged_listview.dart';
import '../widgets/error_indicator.dart';
import 'post_deal.dart';

class Deals extends StatefulWidget {
  const Deals({Key? key}) : super(key: key);

  @override
  _DealsState createState() => _DealsState();
}

class _DealsState extends State<Deals> {
  late DealSortBy _dealSortBy;
  late PagingController<int, Deal> _pagingController;
  int _selectedFilter = 0;
  bool _searchMode = false;
  late final FloatingSearchBarController _searchBarController;

  @override
  void initState() {
    _dealSortBy = DealSortBy.createdAt;
    _pagingController = PagingController<int, Deal>(firstPageKey: 0);
    _searchBarController = FloatingSearchBarController();
    super.initState();
  }

  @override
  void dispose() {
    _searchBarController.dispose();
    _pagingController.dispose();
    super.dispose();
  }

  void _sortDeals(int index) {
    if (index == 0) {
      _dealSortBy = DealSortBy.createdAt;
    } else if (index == 1) {
      _dealSortBy = DealSortBy.dealScore;
    } else if (index == 2) {
      _dealSortBy = DealSortBy.price;
    }
    _pagingController.refresh();
  }

  Future<List<Deal>?> _dealFuture(int page, int size) =>
      GetIt.I.get<SpringService>().getDealsSortedBy(
            dealSortBy: _dealSortBy,
            page: page,
            size: size,
          );

  Widget buildNoDealsFound(BuildContext context) {
    return ErrorIndicator(
      icon: Icons.local_offer,
      title: AppLocalizations.of(context)!.couldNotFindAnyDeal,
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final MyUser? user = Provider.of<UserController>(context).user;
    final List<String> _filterChoices = [
      AppLocalizations.of(context)!.newest,
      AppLocalizations.of(context)!.mostLiked,
      AppLocalizations.of(context)!.cheapest,
    ];

    Widget _buildChoiceChips() {
      return SizedBox(
        height: kToolbarHeight,
        child: Material(
          color: theme.backgroundColor,
          elevation: isDarkMode ? 0 : 4,
          shadowColor: const Color(0xFF000000),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (BuildContext context, int index) {
              return ChoiceChip(
                labelStyle: TextStyle(
                  color: _selectedFilter == index
                      ? Colors.white
                      : theme.primaryColorLight,
                  fontWeight: FontWeight.bold,
                ),
                labelPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                side: BorderSide(
                  color: _selectedFilter == index
                      ? Colors.transparent
                      : theme.primaryColor,
                ),
                pressElevation: 0,
                elevation: _selectedFilter == index ? 4 : 0,
                backgroundColor: theme.backgroundColor,
                selectedColor: theme.primaryColor,
                label: Text(_filterChoices.elementAt(index)),
                selected: _selectedFilter == index,
                onSelected: (bool selected) {
                  if (_selectedFilter != index) {
                    _selectedFilter = index;
                    setState(() {});
                    _sortDeals(_selectedFilter);
                  }
                },
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(width: 8);
            },
          ),
        ),
      );
    }

    Widget _buildPagedListView() {
      return DealPagedListView(
        dealFuture: _dealFuture,
        pagingController: _pagingController,
        noDealsFound: buildNoDealsFound(context),
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
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: _buildActions(),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: _buildChoiceChips(),
        ),
      );
    }

    return Scaffold(
      appBar: _searchMode ? null : _buildAppBar(),
      body: _searchMode ? _buildSearchBar() : _buildPagedListView(),
      resizeToAvoidBottomInset: false,
    );
  }
}

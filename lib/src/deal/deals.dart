import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:line_icons/line_icons.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:provider/provider.dart';

import '../app_localizations.dart';
import '../models/deal.dart';
import '../models/my_user.dart';
import '../models/search_hit.dart';
import '../models/user_controller_impl.dart';
import '../services/spring_service.dart';
import '../utils/navigation_util.dart';
import '../widgets/deal_list_item_builder.dart';
import 'post_deal.dart';
import 'search_deals.dart';

class Deals extends StatefulWidget {
  const Deals({Key? key}) : super(key: key);

  @override
  _DealsState createState() => _DealsState();
}

class _DealsState extends State<Deals> {
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();
  late Future<List<Deal>?> dealsFuture;
  int _selectedFilter = 0;
  late FloatingSearchBarController floatingSearchBarController;
  bool searchErrorOccurred = false;
  bool searchProgress = false;
  final List<String> searchResults = <String>[];

  void _sortDeals(int index) {
    if (index == 0) {
      dealsFuture = GetIt.I.get<SpringService>().getDealsSortedByCreatedAt();
    } else if (index == 1) {
      dealsFuture = GetIt.I.get<SpringService>().getDealsSortedByDealScore();
    } else if (index == 2) {
      dealsFuture = GetIt.I.get<SpringService>().getDealsSortedByPrice();
    }
  }

  @override
  void initState() {
    floatingSearchBarController = FloatingSearchBarController();
    dealsFuture = GetIt.I.get<SpringService>().getDealsSortedByCreatedAt();
    super.initState();
  }

  @override
  void dispose() {
    floatingSearchBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MyUser? user = Provider.of<UserControllerImpl>(context).user;

    final List<String> _filterChoices = <String>[
      AppLocalizations.of(context)!.newest,
      AppLocalizations.of(context)!.mostLiked,
      AppLocalizations.of(context)!.cheapest,
    ];

    Widget buildChoiceChips() {
      return Container(
        height: 65,
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: theme.shadowColor.withOpacity(.2),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
          color: theme.backgroundColor,
        ),
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
              pressElevation: 0.0,
              elevation: _selectedFilter == index ? 4 : 0,
              backgroundColor: theme.backgroundColor,
              selectedColor: theme.primaryColor,
              label: Text(_filterChoices.elementAt(index)),
              selected: _selectedFilter == index,
              onSelected: (bool selected) {
                if (_selectedFilter != index) {
                  _selectedFilter = index;
                  _sortDeals(_selectedFilter);
                  setState(() {});
                }
              },
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(width: 8);
          },
        ),
      );
    }

    Future<void> onRefresh() async {
      dealsFuture = GetIt.I.get<SpringService>().getDealsSortedByCreatedAt();
      setState(() {});

      if (mounted) {
        setState(() {});
      }
    }

    Widget buildNoDealFound() {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: 1,
        itemBuilder: (BuildContext context, int index) {
          return Text(
            AppLocalizations.of(context)!.couldNotFindAnyDeal,
            textAlign: TextAlign.center,
          );
        },
      );
    }

    Widget buildFutureBuilder() {
      return FutureBuilder<List<Deal>?>(
        future: dealsFuture,
        builder: (BuildContext context, AsyncSnapshot<List<Deal>?> snapshot) {
          if (snapshot.hasData) {
            final List<Deal> deals = snapshot.data!;

            if (deals.isEmpty) {
              return buildNoDealFound();
            }

            return DealListItemBuilder(deals: deals);
          } else if (snapshot.hasError) {
            print(snapshot.error);

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return Text(
                  AppLocalizations.of(context)!.anErrorOccurred,
                  textAlign: TextAlign.center,
                );
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    Widget buildBody() {
      return Column(
        children: <Widget>[
          const SizedBox(height: 120),
          buildChoiceChips(),
          Expanded(
            child: RefreshIndicator(
              key: _refreshKey,
              onRefresh: onRefresh,
              child: buildFutureBuilder(),
            ),
          ),
        ],
      );
    }

    Future<void> searchDeals(String keyword) async {
      setState(() {
        searchProgress = true;
      });

      late List<SearchHit> searchHits;
      try {
        searchHits =
            await GetIt.I.get<SpringService>().searchDeals(keyword: keyword);
      } on Exception catch (e) {
        print(e);
        setState(() {
          searchErrorOccurred = true;
          searchProgress = false;
        });
        return;
      }

      searchResults.clear();
      searchHits.forEach((SearchHit e) {
        searchResults.add(e.content.title);
        //   if (e.highlightFields.title != null) {
        //     _searchResults.add(e.highlightFields.title!.first);
        //   } else {
        //     _searchResults.add(e.content.title);
        //   }
      });

      setState(() {
        searchErrorOccurred = false;
        searchProgress = false;
      });
    }

    Widget buildFloatingSearchBar() {
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

      Widget buildSearchResults() {
        return ListView.separated(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: min(searchResults.length, 5),
          itemBuilder: (BuildContext context, int index) {
            final String keyword = searchResults.elementAt(index);

            return Material(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              color: Colors.transparent,
              child: InkWell(
                onTap: () => NavigationUtil.navigate(
                  context,
                  SearchDeals(keyword: keyword),
                ),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                highlightColor: theme.primaryColorLight.withOpacity(.1),
                splashColor: theme.primaryColorLight.withOpacity(.1),
                child: ListTile(
                  leading: const Icon(Icons.search),
                  title: Text(keyword),
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(height: 0),
        );
      }

      Widget buildSearchResultBuilder() {
        // TODO(halildurmus): Add support for displaying recent searches.
        return Material(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: searchErrorOccurred
              ? buildSearchError()
              : floatingSearchBarController.query.isEmpty
                  ? buildPlaceHolder()
                  : searchResults.isEmpty
                      ? buildNoResults()
                      : buildSearchResults(),
        );
      }

      final bool isPortrait =
          MediaQuery.of(context).orientation == Orientation.portrait;

      return FloatingSearchBar(
        controller: floatingSearchBarController,
        progress: searchProgress,
        hint: AppLocalizations.of(context)!.search,
        scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
        transitionDuration: const Duration(milliseconds: 500),
        transitionCurve: Curves.easeInOut,
        physics: const BouncingScrollPhysics(),
        axisAlignment: isPortrait ? 0 : -1,
        openAxisAlignment: 0,
        width: isPortrait ? 600 : 500,
        debounceDelay: const Duration(milliseconds: 500),
        onSubmitted: (String query) {
          NavigationUtil.navigate(context, SearchDeals(keyword: query));
        },
        onQueryChanged: (String query) => searchDeals(query),
        transition: CircularFloatingSearchBarTransition(),
        actions: <Widget>[
          FloatingSearchBarAction.searchToClear(showIfClosed: false)
        ],
        leadingActions: <Widget>[
          FloatingSearchBarAction.back(),
          FloatingSearchBarAction.icon(
            onTap: () {},
            icon: const Icon(Icons.search),
          )
        ],
        builder: (BuildContext context, Animation<double> transition) =>
            buildSearchResultBuilder(),
      );
    }

    Widget buildFAB() {
      return FloatingActionButton.extended(
        onPressed: () {
          NavigationUtil.navigate(context, const PostDeal())
              .then((dynamic value) {
            setState(() {
              dealsFuture =
                  GetIt.I.get<SpringService>().getDealsSortedByCreatedAt();
            });
          });
        },
        elevation: 3,
        icon: const Icon(LineIcons.tags),
        label: Text(AppLocalizations.of(context)!.post),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          buildBody(),
          buildFloatingSearchBar(),
        ],
      ),
      floatingActionButton: user != null ? buildFAB() : null,
      resizeToAvoidBottomInset: false,
    );
  }
}

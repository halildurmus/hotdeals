import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart'
    show PagingController;

import '../deal/deal_paged_listview.dart';
import '../models/category.dart';
import '../models/deal.dart';
import '../services/api_repository.dart';
import '../utils/localization_util.dart';
import '../widgets/error_indicator.dart';
import 'filter_chips.dart';

class DealsByCategory extends StatefulWidget {
  const DealsByCategory({required this.category, Key? key}) : super(key: key);

  final Category category;

  @override
  _DealsByCategoryState createState() => _DealsByCategoryState();
}

class _DealsByCategoryState extends State<DealsByCategory> {
  late Category category;
  late PagingController<int, Deal> _pagingController;

  @override
  void initState() {
    category = widget.category;
    _pagingController = PagingController<int, Deal>(firstPageKey: 0);
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  PreferredSizeWidget buildAppBar() => PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          centerTitle: true,
          title: Text(category.localizedName(Localizations.localeOf(context))),
        ),
      );

  Future<List<Deal>> _dealFuture(int page, int size) =>
      GetIt.I.get<APIRepository>().getDealsByCategory(
            category: category.category,
            page: page,
            size: size,
          );

  Widget buildFilterChips() => FilterChips(
        category: widget.category,
        onFilterChange: (newCategory) {
          setState(() {
            category = newCategory;
            _pagingController.refresh();
          });
        },
      );

  Widget buildNoDealsFound(BuildContext context) => ErrorIndicator(
        icon: Icons.local_offer,
        title: l(context).couldNotFindAnyDeal,
      );

  Widget buildPagedListView() => DealPagedListView(
        dealsFuture: _dealFuture,
        noDealsFound: buildNoDealsFound(context),
        pagingController: _pagingController,
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: buildAppBar(),
        body: Column(
          children: [
            buildFilterChips(),
            Expanded(child: buildPagedListView()),
          ],
        ),
      );
}

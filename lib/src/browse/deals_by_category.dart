import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart'
    show PagingController;

import '../models/category.dart';
import '../models/deal.dart';
import '../services/spring_service.dart';
import '../widgets/deal_paged_listview.dart';
import '../widgets/error_indicator.dart';
import 'filter_chips.dart';

class DealsByCategory extends StatefulWidget {
  const DealsByCategory({Key? key, required this.category}) : super(key: key);

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

  PreferredSizeWidget buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: AppBar(
        centerTitle: true,
        title: Text(category.localizedName(Localizations.localeOf(context))),
      ),
    );
  }

  Future<List<Deal>?> _dealFuture(int page, int size) =>
      GetIt.I.get<SpringService>().getDealsByCategory(
            category: category.category,
            page: page,
            size: size,
          );

  Widget buildFilterChips() {
    return FilterChips(
        category: widget.category,
        onFilterChange: (newCategory) {
          setState(() {
            category = newCategory;
            _pagingController.refresh();
          });
        });
  }

  Widget buildNoDealsFound(BuildContext context) {
    return ErrorIndicator(
      icon: Icons.local_offer,
      title: AppLocalizations.of(context)!.couldNotFindAnyDeal,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget buildPagedListView() {
      return DealPagedListView(
        dealFuture: _dealFuture,
        pagingController: _pagingController,
        noDealsFound: buildNoDealsFound(context),
      );
    }

    return Scaffold(
      appBar: buildAppBar(),
      body: Column(
        children: [
          buildFilterChips(),
          Expanded(child: buildPagedListView()),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../app_localizations.dart';
import '../models/categories.dart';
import '../models/category.dart';
import '../models/deal.dart';
import '../services/spring_service.dart';
import '../widgets/deal_list_item_builder.dart';

class DealsByCategory extends StatefulWidget {
  const DealsByCategory({Key? key, required this.category}) : super(key: key);

  final Category category;

  @override
  _DealsByCategoryState createState() => _DealsByCategoryState();
}

class _DealsByCategoryState extends State<DealsByCategory> {
  late Category category;
  late List<Category> subcategories;
  late Future<List<Deal>?> dealsFuture;
  int selectedFilter = -1;
  bool isFavorited = false;

  @override
  void initState() {
    category = widget.category;
    subcategories =
        GetIt.I.get<Categories>().getSubcategories(category: category);
    dealsFuture = GetIt.I
        .get<SpringService>()
        .getDealsByCategory(category: category.category);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    Future<void> onRefresh() async {
      dealsFuture = GetIt.I
          .get<SpringService>()
          .getDealsByCategory(category: category.category);
      setState(() {});

      if (mounted) {
        setState(() {});
      }
    }

    Widget buildFilterChips() {
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
          itemCount: subcategories.length,
          itemBuilder: (BuildContext context, int index) {
            final Category subcategory = subcategories.elementAt(index);

            return FilterChip(
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: selectedFilter == index
                    ? Colors.white
                    : theme.primaryColorLight,
                fontWeight: FontWeight.bold,
              ),
              labelPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              side: BorderSide(
                color: selectedFilter == index
                    ? Colors.transparent
                    : theme.primaryColor,
              ),
              pressElevation: 0.0,
              elevation: selectedFilter == index ? 4 : 0,
              backgroundColor: theme.backgroundColor,
              label: Text(subcategory.name),
              selectedColor: theme.primaryColor,
              selected: selectedFilter == index,
              onSelected: (bool selected) {
                if (selected) {
                  selectedFilter = index;
                  category = subcategory;
                  dealsFuture = GetIt.I
                      .get<SpringService>()
                      .getDealsByCategory(category: category.category);
                  setState(() {});
                } else {
                  selectedFilter = -1;
                  category = widget.category;
                  dealsFuture = GetIt.I
                      .get<SpringService>()
                      .getDealsByCategory(category: widget.category.category);
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

    Widget buildFutureBuilder() {
      return FutureBuilder<List<Deal>?>(
        future: dealsFuture,
        builder: (BuildContext context, AsyncSnapshot<List<Deal>?> snapshot) {
          if (snapshot.hasData) {
            final List<Deal> deals = snapshot.data!;

            if (deals.isEmpty) {
              return Center(
                child: Text(AppLocalizations.of(context)!.couldNotFindAnyDeal),
              );
            }

            return DealListItemBuilder(deals: deals);
          } else if (snapshot.hasError) {
            print(snapshot.error);

            return Center(
              child: Text(AppLocalizations.of(context)!.anErrorOccurred),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    PreferredSizeWidget buildAppBar() {
      return PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(centerTitle: true, title: Text(category.name)),
      );
    }

    Widget buildBody() {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: Column(
          children: <Widget>[
            if (subcategories.isNotEmpty) buildFilterChips(),
            Expanded(child: buildFutureBuilder()),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(),
    );
  }
}

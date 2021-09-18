import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../models/categories.dart';
import '../models/category.dart';
import '../utils/navigation_util.dart';
import '../widgets/category_item.dart';
import 'deals_by_category.dart';

class BrowseCategories extends StatefulWidget {
  const BrowseCategories({Key? key}) : super(key: key);

  @override
  State<BrowseCategories> createState() => _BrowseCategoriesState();
}

class _BrowseCategoriesState extends State<BrowseCategories> {
  late List<Category> categories;

  @override
  void initState() {
    categories = GetIt.I.get<Categories>().mainCategories!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget buildCategories() {
      return ListView.builder(
        itemCount: categories.length,
        itemBuilder: (BuildContext context, int index) {
          final Category category = categories[index];

          return CategoryItem(
            onTap: () => NavigationUtil.navigate(
              context,
              DealsByCategory(category: category),
            ),
            category: category,
          );
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: buildCategories(),
    );
  }
}

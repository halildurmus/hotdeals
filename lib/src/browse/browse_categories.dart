import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../models/categories.dart';
import '../models/category.dart';
import '../utils/navigation_util.dart';
import 'category_item.dart';
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
    categories = GetIt.I.get<Categories>().mainCategories;
    super.initState();
  }

  Widget buildCategories() => ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];

          return CategoryItem(
            onTap: () => NavigationUtil.navigate(
              context,
              DealsByCategory(category: category),
            ),
            category: category,
          );
        },
      );

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: buildCategories(),
      );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/categories_provider.dart';
import 'category_item.dart';

class BrowseCategoriesTab extends ConsumerWidget {
  const BrowseCategoriesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider).mainCategories;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (_, index) => CategoryItem(category: categories[index]),
      ),
    );
  }
}

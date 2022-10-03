import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../helpers/context_extensions.dart';
import '../data/categories_provider.dart';
import '../data/stores_provider.dart';
import 'widgets/category_item.dart';
import 'widgets/store_item.dart';

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: Size.zero,
            child: TabBar(
              isScrollable: true,
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              tabs: [
                Tab(text: context.l.categories),
                Tab(text: context.l.stores),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            _BrowseCategoriesTab(),
            _BrowseStoresTab(),
          ],
        ),
      ),
    );
  }
}

class _BrowseCategoriesTab extends ConsumerWidget {
  const _BrowseCategoriesTab();

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

class _BrowseStoresTab extends ConsumerWidget {
  const _BrowseStoresTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stores = ref.watch(storesProvider).stores;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          childAspectRatio: 1.2,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          maxCrossAxisExtent: 200,
        ),
        itemCount: stores.length,
        itemBuilder: (_, index) => StoreItem(store: stores[index]),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/stores_provider.dart';
import 'store_item.dart';

class BrowseStoresTab extends ConsumerWidget {
  const BrowseStoresTab({super.key});

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

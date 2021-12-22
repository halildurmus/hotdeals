import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../models/store.dart';
import '../models/stores.dart';
import '../utils/navigation_util.dart';
import 'deals_by_store.dart';
import 'store_item.dart';

class BrowseStores extends StatefulWidget {
  const BrowseStores({Key? key}) : super(key: key);

  @override
  State<BrowseStores> createState() => _BrowseStoresState();
}

class _BrowseStoresState extends State<BrowseStores> {
  late List<Store> stores;

  @override
  void initState() {
    stores = GetIt.I.get<Stores>().stores!;
    super.initState();
  }

  Widget buildStores() => GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          childAspectRatio: 1.2,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          maxCrossAxisExtent: 200,
        ),
        itemCount: stores.length,
        itemBuilder: (context, index) {
          final store = stores[index];

          return StoreItem(
            onTap: () => NavigationUtil.navigate(
              context,
              DealsByStore(store: store),
            ),
            store: store,
          );
        },
      );

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: buildStores(),
      );
}

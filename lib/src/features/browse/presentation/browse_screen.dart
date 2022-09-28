import 'package:flutter/material.dart';

import '../../../helpers/context_extensions.dart';
import 'widgets/browse_categories_tab.dart';
import 'widgets/browse_stores_tab.dart';

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
            BrowseCategoriesTab(),
            BrowseStoresTab(),
          ],
        ),
      ),
    );
  }
}

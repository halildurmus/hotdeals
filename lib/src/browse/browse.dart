import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'browse_categories.dart';
import 'browse_stores.dart';

class Browse extends StatefulWidget {
  const Browse({Key? key}) : super(key: key);

  @override
  _BrowseState createState() => _BrowseState();
}

class _BrowseState extends State<Browse> with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(vsync: this, length: 2);
    super.initState();
  }

  PreferredSizeWidget buildAppBar() {
    return AppBar(
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: TabBar(
            controller: tabController,
            isScrollable: true,
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            tabs: [
              Tab(text: AppLocalizations.of(context)!.categories),
              Tab(text: AppLocalizations.of(context)!.stores),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBody() {
    return TabBarView(
      controller: tabController,
      children: const [BrowseCategories(), BrowseStores()],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(),
    );
  }
}

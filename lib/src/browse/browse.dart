import 'package:flutter/material.dart';

import '../utils/localization_util.dart';
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

  PreferredSizeWidget buildAppBar() => AppBar(
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
                Tab(text: l(context).categories),
                Tab(text: l(context).stores),
              ],
            ),
          ),
        ),
      );

  Widget buildBody() => TabBarView(
        controller: tabController,
        children: const [BrowseCategories(), BrowseStores()],
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: buildAppBar(),
        body: buildBody(),
      );
}

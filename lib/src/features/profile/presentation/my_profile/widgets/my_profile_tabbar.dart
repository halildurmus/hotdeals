import 'package:flutter/material.dart';

import '../../../../../helpers/context_extensions.dart';

class MyProfileTabBar extends StatelessWidget {
  const MyProfileTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TabBar(
        indicatorColor: context.isLightMode ? context.t.primaryColor : null,
        indicatorSize: TabBarIndicatorSize.label,
        isScrollable: true,
        labelColor: context.isLightMode ? context.t.primaryColor : null,
        unselectedLabelColor:
            context.isLightMode ? context.t.primaryColorLight : null,
        labelStyle: context.textTheme.bodyText2!.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        tabs: [
          Tab(text: context.l.posts),
          Tab(text: context.l.favorites),
        ],
      ),
    );
  }
}

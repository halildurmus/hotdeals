import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../deal/deal_paged_listview.dart';
import '../models/deal.dart';
import '../services/api_repository.dart';
import '../utils/localization_util.dart';
import '../widgets/error_indicator.dart';

class MyFavorites extends StatelessWidget {
  const MyFavorites({Key? key}) : super(key: key);

  Future<List<Deal>> _dealFuture(int page, int size) =>
      GetIt.I.get<APIRepository>().getUserFavorites(page: page, size: size);

  Widget buildNoDealsFound(BuildContext context) => ErrorIndicator(
        icon: Icons.favorite_outline,
        title: l(context).noFavoritesYet,
        message: l(context).noFavoritesYetDescription,
      );

  @override
  Widget build(BuildContext context) => DealPagedListView(
        dealsFuture: _dealFuture,
        noDealsFound: buildNoDealsFound(context),
        pageSize: 8,
        removeDealWhenUnfavorited: true,
      );
}

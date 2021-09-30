import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';

import '../models/deal.dart';
import '../services/spring_service.dart';
import '../widgets/deal_paged_listview.dart';
import '../widgets/error_indicator.dart';

class MyFavorites extends StatelessWidget {
  const MyFavorites({Key? key}) : super(key: key);

  Widget buildNoDealsFound(BuildContext context) {
    return ErrorIndicator(
      icon: Icons.favorite_outline,
      title: AppLocalizations.of(context)!.noFavoritesYet,
      message: AppLocalizations.of(context)!.noFavoritesYetDescription,
    );
  }

  @override
  Widget build(BuildContext context) {
    Future<List<Deal>?> _dealFuture(int page, int size) =>
        GetIt.I.get<SpringService>().getUserFavorites(page: page, size: size);

    return DealPagedListView(
      dealFuture: _dealFuture,
      noDealsFound: buildNoDealsFound(context),
      pageSize: 8,
    );
  }
}

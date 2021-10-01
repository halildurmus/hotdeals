import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';

import '../models/deal.dart';
import '../services/spring_service.dart';
import '../widgets/deal_paged_listview.dart';
import '../widgets/error_indicator.dart';

class SearchDeals extends StatelessWidget {
  const SearchDeals({Key? key, required this.keyword}) : super(key: key);

  final String keyword;

  PreferredSizeWidget buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: AppBar(centerTitle: true, title: Text('"$keyword"')),
    );
  }

  Future<List<Deal>?> _dealFuture(int page, int size) =>
      GetIt.I.get<SpringService>().getDealsByKeyword(
            keyword: keyword,
            page: page,
            size: size,
          );

  Widget buildNoDealsFound(BuildContext context) {
    return ErrorIndicator(
      icon: Icons.local_offer,
      title: AppLocalizations.of(context)!.couldNotFindAnyDeal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: DealPagedListView(
        dealFuture: _dealFuture,
        noDealsFound: buildNoDealsFound(context),
      ),
    );
  }
}

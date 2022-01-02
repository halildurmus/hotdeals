import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../deal/deal_paged_listview.dart';
import '../models/deal.dart';
import '../services/api_repository.dart';
import '../utils/localization_util.dart';
import '../widgets/error_indicator.dart';

class MyDeals extends StatelessWidget {
  const MyDeals({Key? key}) : super(key: key);

  Future<List<Deal>> _dealFuture(int page, int size) =>
      GetIt.I.get<APIRepository>().getUserDeals(page: page, size: size);

  Widget buildNoDealsFound(BuildContext context) => ErrorIndicator(
        icon: Icons.local_offer,
        title: l(context).noPostsYet,
      );

  @override
  Widget build(BuildContext context) => DealPagedListView(
        dealsFuture: _dealFuture,
        noDealsFound: buildNoDealsFound(context),
        pageSize: 8,
      );
}

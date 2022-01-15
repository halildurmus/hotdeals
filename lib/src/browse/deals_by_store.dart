import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../deal/deal_paged_listview.dart';
import '../models/deal.dart';
import '../models/store.dart';
import '../services/api_repository.dart';
import '../utils/localization_util.dart';
import '../widgets/error_indicator.dart';

class DealsByStore extends StatelessWidget {
  const DealsByStore({required this.store, Key? key}) : super(key: key);

  final Store store;

  PreferredSizeWidget buildAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: AppBar(
        centerTitle: true,
        title: Container(
          color: theme.brightness == Brightness.dark ? Colors.white : null,
          padding: theme.brightness == Brightness.dark
              ? const EdgeInsets.all(3)
              : EdgeInsets.zero,
          height: 55,
          width: 55,
          child: CachedNetworkImage(
            imageUrl: store.logo,
            imageBuilder: (ctx, imageProvider) => Hero(
              tag: store.id!,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(image: imageProvider),
                ),
              ),
            ),
            placeholder: (context, url) => const SizedBox.square(dimension: 50),
          ),
        ),
      ),
    );
  }

  Future<List<Deal>> _dealFuture(int page, int size) =>
      GetIt.I.get<APIRepository>().getDealsByStore(
            storeId: store.id!,
            page: page,
            size: size,
          );

  Widget buildNoDealsFound(BuildContext context) => ErrorIndicator(
        icon: Icons.local_offer,
        title: l(context).couldNotFindAnyDeal,
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: buildAppBar(context),
        body: DealPagedListView(
          dealsFuture: _dealFuture,
          noDealsFound: buildNoDealsFound(context),
        ),
      );
}

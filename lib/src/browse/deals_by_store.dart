import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';

import '../models/deal.dart';
import '../models/store.dart';
import '../services/spring_service.dart';
import '../widgets/deal_paged_listview.dart';
import '../widgets/error_indicator.dart';

class DealsByStore extends StatelessWidget {
  const DealsByStore({Key? key, required this.store}) : super(key: key);

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
            imageBuilder:
                (BuildContext ctx, ImageProvider<Object> imageProvider) {
              return Hero(
                tag: store.id!,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    image: DecorationImage(image: imageProvider),
                  ),
                ),
              );
            },
            placeholder: (BuildContext context, String url) =>
                const SizedBox.square(dimension: 50),
          ),
        ),
      ),
    );
  }

  Future<List<Deal>?> _dealFuture(int page, int size) =>
      GetIt.I.get<SpringService>().getDealsByStore(
            storeId: store.id!,
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
      appBar: buildAppBar(context),
      body: DealPagedListView(
        dealFuture: _dealFuture,
        noDealsFound: buildNoDealsFound(context),
      ),
    );
  }
}

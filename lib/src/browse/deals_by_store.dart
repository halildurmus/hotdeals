import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../app_localizations.dart';
import '../models/deal.dart';
import '../models/store.dart';
import '../services/spring_service.dart';
import '../widgets/deal_list_item_builder.dart';

class DealsByStore extends StatefulWidget {
  const DealsByStore({Key? key, required this.store}) : super(key: key);

  final Store store;

  @override
  _DealsByStoreState createState() => _DealsByStoreState();
}

class _DealsByStoreState extends State<DealsByStore> {
  late Future<List<Deal>?> dealsFuture;
  bool isFavorited = false;

  @override
  void initState() {
    dealsFuture =
        GetIt.I.get<SpringService>().getDealsByStore(storeId: widget.store.id!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Store store = widget.store;

    Future<void> onRefresh() async {
      dealsFuture = GetIt.I
          .get<SpringService>()
          .getDealsByStore(storeId: widget.store.id!);
      setState(() {});

      if (mounted) {
        setState(() {});
      }
    }

    Widget buildFutureBuilder() {
      return FutureBuilder<List<Deal>?>(
        future: dealsFuture,
        builder: (BuildContext context, AsyncSnapshot<List<Deal>?> snapshot) {
          if (snapshot.hasData) {
            final List<Deal> deals = snapshot.data!;

            if (deals.isEmpty) {
              return Center(
                child: Text(AppLocalizations.of(context)!.couldNotFindAnyDeal),
              );
            }

            return DealListItemBuilder(deals: deals);
          } else if (snapshot.hasError) {
            print(snapshot.error);

            return Center(
              child: Text(AppLocalizations.of(context)!.anErrorOccurred),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    PreferredSizeWidget buildAppBar() {
      return PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          centerTitle: true,
          title: Container(
            color: theme.brightness == Brightness.dark ? Colors.white : null,
            padding: theme.brightness == Brightness.dark
                ? const EdgeInsets.all(4)
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
                  const SizedBox(height: 50, width: 50),
            ),
          ),
        ),
      );
    }

    Widget buildBody() {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: buildFutureBuilder(),
      );
    }

    return Scaffold(appBar: buildAppBar(), body: buildBody());
  }
}

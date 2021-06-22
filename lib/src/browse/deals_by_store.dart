import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

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
              return const Center(child: Text('Could not find any deal'));
            }

            return DealListItemBuilder(deals: deals);
          } else if (snapshot.hasError) {
            print(snapshot.error);

            return const Center(child: Text('An error occurred!'));
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
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(8),
            child: Image.network(store.logo, height: 70, width: 70),
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

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../models/deal.dart';
import '../services/spring_service.dart';
import '../widgets/deal_list_item_builder.dart';

class SearchDeals extends StatefulWidget {
  const SearchDeals({Key? key, required this.keyword}) : super(key: key);

  final String keyword;

  @override
  _SearchDealsState createState() => _SearchDealsState();
}

class _SearchDealsState extends State<SearchDeals> {
  late Future<List<Deal>?> dealsFuture;
  bool isFavorited = false;

  @override
  void initState() {
    dealsFuture =
        GetIt.I.get<SpringService>().getDealsByKeyword(keyword: widget.keyword);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> onRefresh() async {
      dealsFuture = GetIt.I
          .get<SpringService>()
          .getDealsByKeyword(keyword: widget.keyword);
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
                child: Text(
                  'Could not find any result for "${widget.keyword}"',
                ),
              );
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
        child: AppBar(centerTitle: true, title: Text('"${widget.keyword}"')),
      );
    }

    Widget buildBody() {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: Column(
          children: <Widget>[
            // _buildSortChips(),
            Expanded(child: buildFutureBuilder()),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(),
    );
  }
}

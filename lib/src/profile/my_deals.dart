import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../app_localizations.dart';
import '../models/deal.dart';
import '../models/my_user.dart';
import '../models/user_controller_impl.dart';
import '../services/spring_service.dart';
import '../widgets/deal_list_item_builder.dart';

class MyDeals extends StatefulWidget {
  const MyDeals({Key? key}) : super(key: key);

  @override
  _MyDealsState createState() => _MyDealsState();
}

class _MyDealsState extends State<MyDeals> {
  late Future<List<Deal>?> _myDealsFuture;

  @override
  void initState() {
    final MyUser user = context.read<UserControllerImpl>().user!;
    _myDealsFuture =
        GetIt.I.get<SpringService>().getDealsByPostedBy(postedBy: user.id!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final MyUser user = Provider.of<UserControllerImpl>(context).user!;

    return FutureBuilder<List<Deal>?>(
      future: _myDealsFuture,
      builder: (BuildContext context, AsyncSnapshot<List<Deal>?> snapshot) {
        if (snapshot.hasData) {
          final List<Deal> deals = snapshot.data!;

          if (deals.isEmpty) {
            return Center(
              child:
                  Text(AppLocalizations.of(context)!.youHaveNotPostedAnyDeal),
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
}

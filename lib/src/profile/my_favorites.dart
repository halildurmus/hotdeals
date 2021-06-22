import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../models/deal.dart';
import '../models/user_controller_impl.dart';
import '../models/my_user.dart';
import '../services/spring_service.dart';
import '../widgets/deal_list_item_builder.dart';

class MyFavorites extends StatefulWidget {
  const MyFavorites({Key? key}) : super(key: key);

  @override
  _MyFavoritesState createState() => _MyFavoritesState();
}

class _MyFavoritesState extends State<MyFavorites> {
  @override
  Widget build(BuildContext context) {
    final MyUser user = Provider.of<UserControllerImpl>(context).user!;

    return FutureBuilder<List<Deal>?>(
      future: GetIt.I.get<SpringService>().getUserFavorites(),
      builder: (BuildContext context, AsyncSnapshot<List<Deal>?> snapshot) {
        if (snapshot.hasData) {
          final List<Deal> deals = snapshot.data!;

          if (deals.isEmpty) {
            return const Center(
              child: Text("You haven't favorited any deal yet!"),
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
}

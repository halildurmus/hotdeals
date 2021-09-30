import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:loggy/loggy.dart' show UiLoggy;
import 'package:provider/provider.dart';

import '../models/deal.dart';
import '../models/my_user.dart';
import '../models/user_controller_impl.dart';
import '../services/spring_service.dart';
import 'deal_list_item.dart';

class DealListItemBuilder extends StatefulWidget {
  const DealListItemBuilder({
    Key? key,
    required this.deals,
    this.padding = const EdgeInsets.only(top: 16, bottom: 60),
  }) : super(key: key);

  final List<Deal> deals;
  final EdgeInsets padding;

  @override
  _DealListItemBuilderState createState() => _DealListItemBuilderState();
}

class _DealListItemBuilderState extends State<DealListItemBuilder>
    with UiLoggy {
  @override
  Widget build(BuildContext context) {
    final MyUser? user = Provider.of<UserControllerImpl>(context).user;

    return ListView.builder(
      padding: widget.padding,
      itemCount: widget.deals.length,
      itemBuilder: (BuildContext context, int index) {
        final Deal deal = widget.deals.elementAt(index);
        final bool isFavorited = user?.favorites![deal.id!] == true;

        return DealListItem(
          deal: deal,
          onFavoriteButtonPressed: () {
            if (user == null) {
              loggy.warning('You need to log in!');

              return;
            }

            if (!isFavorited) {
              GetIt.I
                  .get<SpringService>()
                  .favoriteDeal(dealId: deal.id!)
                  .then((bool result) {
                if (result) {
                  Provider.of<UserControllerImpl>(context, listen: false)
                      .getUser();
                }
              });
            } else {
              GetIt.I
                  .get<SpringService>()
                  .unfavoriteDeal(dealId: deal.id!)
                  .then((bool result) {
                if (result) {
                  Provider.of<UserControllerImpl>(context, listen: false)
                      .getUser();
                }
              });
            }
          },
          index: index,
          isFavorited: isFavorited,
        );
      },
    );
  }
}

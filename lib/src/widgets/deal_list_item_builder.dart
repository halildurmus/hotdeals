import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:loggy/loggy.dart' show UiLoggy;
import 'package:provider/provider.dart';

import '../deal/deal_details.dart';
import '../models/deal.dart';
import '../models/my_user.dart';
import '../models/user_controller_impl.dart';
import '../services/spring_service.dart';
import '../utils/navigation_util.dart';
import 'deal_list_item.dart';

class DealListItemBuilder extends StatefulWidget {
  const DealListItemBuilder({Key? key, required this.deals}) : super(key: key);

  final List<Deal> deals;

  @override
  _DealListItemBuilderState createState() => _DealListItemBuilderState();
}

class _DealListItemBuilderState extends State<DealListItemBuilder>
    with UiLoggy {
  Widget _getFavoritesButton(
      VoidCallback onFavoritesClick, bool isFavorited, int index) {
    final ThemeData theme = Theme.of(context);

    return FloatingActionButton(
      heroTag: 'btn$index',
      mini: true,
      backgroundColor: theme.backgroundColor,
      onPressed: onFavoritesClick,
      child: Icon(
        isFavorited ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
        color: theme.primaryColor,
        size: 18.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MyUser? user = Provider.of<UserControllerImpl>(context).user;

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 60),
      itemCount: widget.deals.length,
      itemBuilder: (BuildContext context, int index) {
        final Deal deal = widget.deals.elementAt(index);
        final bool isFavorited = user?.favorites![deal.id!] == true;

        return DealListItem(
          onTap: () =>
              NavigationUtil.navigate(context, DealDetails(deal: deal)),
          deal: deal,
          bottomRoundButton: _getFavoritesButton(() {
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
          }, isFavorited, index),
          specialMark:
              deal.isNew! ? AppLocalizations.of(context)!.newMark : null,
        );
      },
    );
  }
}

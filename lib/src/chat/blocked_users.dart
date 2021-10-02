import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../models/my_user.dart';
import '../models/user_controller_impl.dart';
import '../services/spring_service.dart';
import '../utils/error_indicator_util.dart';
import '../widgets/custom_alert_dialog.dart';
import '../widgets/error_indicator.dart';

class BlockedUsers extends StatefulWidget {
  const BlockedUsers({Key? key}) : super(key: key);

  static const String routeName = '/blocked-users';

  @override
  _BlockedUsersState createState() => _BlockedUsersState();
}

class _BlockedUsersState extends State<BlockedUsers> {
  Widget buildNoBlockedUsersFound(BuildContext context) {
    return ErrorIndicator(
      icon: Icons.person_outline,
      title: AppLocalizations.of(context)!.noBlockedUsers,
    );
  }

  Widget buildErrorWidget() {
    return ErrorIndicatorUtil.buildFirstPageError(
      context,
      onTryAgain: () => setState(() {}),
    );
  }

  Widget buildCard(MyUser user, BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () {},
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        highlightColor: theme.primaryColorLight.withOpacity(.1),
        splashColor: theme.primaryColorLight.withOpacity(.1),
        child: ListTile(
          leading: CachedNetworkImage(
            imageUrl: user.avatar!,
            imageBuilder:
                (BuildContext ctx, ImageProvider<Object> imageProvider) =>
                    CircleAvatar(backgroundImage: imageProvider, radius: 24),
            placeholder: (BuildContext context, String url) =>
                const CircleAvatar(),
          ),
          title: Text(user.nickname!, style: theme.textTheme.bodyText1),
          trailing: OutlinedButton(
            onPressed: () => confirmUnblockUser(context, user.uid),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              side: BorderSide(color: theme.errorColor),
            ),
            child: Text(
              AppLocalizations.of(context)!.unblock,
              style: theme.textTheme.subtitle2!.copyWith(
                color: theme.errorColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> confirmUnblockUser(BuildContext context, String userUid) async {
    final bool didRequestUnblockUser = await CustomAlertDialog(
          title: AppLocalizations.of(context)!.unblockUser,
          content: AppLocalizations.of(context)!.unblockConfirm,
          cancelActionText: AppLocalizations.of(context)!.cancel,
          defaultActionText: AppLocalizations.of(context)!.ok,
        ).show(context) ??
        false;

    if (didRequestUnblockUser == true) {
      final bool result =
          await GetIt.I.get<SpringService>().unblockUser(userUid: userUid);

      if (result) {
        await Provider.of<UserControllerImpl>(context, listen: false).getUser();

        final SnackBar snackBar = SnackBar(
          content: Row(
            children: <Widget>[
              const Icon(FontAwesomeIcons.checkCircle, size: 20.0),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    AppLocalizations.of(context)!.successfullyUnblocked,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        );

        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
      } else {
        final SnackBar snackBar = SnackBar(
          content: Row(
            children: <Widget>[
              const Icon(FontAwesomeIcons.exclamationCircle, size: 20.0),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    AppLocalizations.of(context)!
                        .anErrorOccurredWhileUnblocking,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final MyUser user = Provider.of<UserControllerImpl>(context).user!;

    Future<void> onRefresh() async {
      await Provider.of<UserControllerImpl>(context, listen: false).getUser();
      setState(() {});

      if (mounted) {
        setState(() {});
      }
    }

    Widget buildBlockedUsers() {
      return FutureBuilder<List<MyUser>?>(
        future: GetIt.I
            .get<SpringService>()
            .getBlockedUsers(userUids: user.blockedUsers!),
        builder: (BuildContext context, AsyncSnapshot<List<MyUser>?> snapshot) {
          if (snapshot.hasData) {
            final List<MyUser> users = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (BuildContext context, int index) {
                  final MyUser user = users.elementAt(index);

                  return buildCard(user, context);
                },
              ),
            );
          } else if (snapshot.hasError) {
            return buildErrorWidget();
          }

          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.blockedUsers),
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: user.blockedUsers!.isEmpty
            ? buildNoBlockedUsersFound(context)
            : buildBlockedUsers(),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../models/my_user.dart';
import '../models/user_controller.dart';
import '../services/spring_service.dart';
import '../utils/error_indicator_util.dart';
import '../widgets/custom_alert_dialog.dart';
import '../widgets/error_indicator.dart';
import '../widgets/user_profile_dialog.dart';

class BlockedUsers extends StatefulWidget {
  const BlockedUsers({Key? key}) : super(key: key);

  static const String routeName = '/blocked-users';

  @override
  _BlockedUsersState createState() => _BlockedUsersState();
}

class _BlockedUsersState extends State<BlockedUsers> {
  Future<void> _onUserTap(String userId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) =>
          UserProfileDialog(userId: userId, hideButtons: true),
    );
  }

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
        onTap: () => _onUserTap(user.id!),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        highlightColor: theme.primaryColorLight.withOpacity(.1),
        splashColor: theme.primaryColorLight.withOpacity(.1),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: CachedNetworkImage(
            imageUrl: user.avatar!,
            imageBuilder:
                (BuildContext ctx, ImageProvider<Object> imageProvider) =>
                    CircleAvatar(backgroundImage: imageProvider),
            placeholder: (BuildContext context, String url) =>
                const CircleAvatar(),
          ),
          title: Text(
            user.nickname!,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          trailing: OutlinedButton(
            onPressed: () => confirmUnblockUser(context, user.uid),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
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
    final theme = Theme.of(context);
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
        await Provider.of<UserController>(context, listen: false).getUser();
        final SnackBar snackBar = SnackBar(
          backgroundColor: theme.backgroundColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          content: Row(
            children: [
              const Icon(FontAwesomeIcons.checkCircle, size: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    AppLocalizations.of(context)!.successfullyUnblocked,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyText2,
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
          backgroundColor: theme.backgroundColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          content: Row(
            children: [
              const Icon(FontAwesomeIcons.exclamationCircle, size: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    AppLocalizations.of(context)!
                        .anErrorOccurredWhileUnblocking,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyText2,
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

  Future<void> onRefresh() async {
    await Provider.of<UserController>(context, listen: false).getUser();
    setState(() {});

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final MyUser user = Provider.of<UserController>(context).user!;

    Widget buildBlockedUsers() {
      return FutureBuilder<List<MyUser>?>(
        future: GetIt.I
            .get<SpringService>()
            .getBlockedUsers(userUids: user.blockedUsers!),
        builder: (BuildContext context, AsyncSnapshot<List<MyUser>?> snapshot) {
          if (snapshot.hasData) {
            final List<MyUser> users = snapshot.data!;

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (BuildContext context, int index) {
                final MyUser user = users.elementAt(index);

                return buildCard(user, context);
              },
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

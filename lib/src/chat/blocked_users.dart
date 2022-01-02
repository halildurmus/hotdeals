import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../models/my_user.dart';
import '../models/user_controller.dart';
import '../services/api_repository.dart';
import '../utils/error_indicator_util.dart';
import '../utils/localization_util.dart';
import '../widgets/custom_alert_dialog.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/error_indicator.dart';
import '../widgets/user_profile_dialog.dart';

class BlockedUsers extends StatefulWidget {
  const BlockedUsers({Key? key}) : super(key: key);

  static const String routeName = '/blocked-users';

  @override
  _BlockedUsersState createState() => _BlockedUsersState();
}

class _BlockedUsersState extends State<BlockedUsers> {
  Future<void> _onUserTap(String userId) async => showDialog<void>(
        context: context,
        builder: (context) =>
            UserProfileDialog(userId: userId, hideButtons: true),
      );

  Widget buildNoBlockedUsersFound(BuildContext context) => ErrorIndicator(
        icon: Icons.person_outline,
        title: l(context).noBlockedUsers,
      );

  Widget buildErrorWidget() => ErrorIndicatorUtil.buildFirstPageError(
        context,
        onTryAgain: () => setState(() {}),
      );

  Widget buildCard(MyUser user, BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        onTap: () => _onUserTap(user.id!),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CachedNetworkImage(
          imageUrl: user.avatar!,
          imageBuilder: (ctx, imageProvider) =>
              CircleAvatar(backgroundImage: imageProvider),
          placeholder: (context, url) => const CircleAvatar(),
        ),
        title: Text(
          user.nickname!,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        trailing: OutlinedButton(
          onPressed: () => confirmUnblockUser(context, user.id!),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            side: BorderSide(color: theme.errorColor),
          ),
          child: Text(
            l(context).unblock,
            style: theme.textTheme.subtitle2!.copyWith(
              color: theme.errorColor,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> confirmUnblockUser(BuildContext context, String userId) async {
    final didRequestUnblockUser = await CustomAlertDialog(
          title: l(context).unblockUser,
          content: l(context).unblockConfirm,
          cancelActionText: l(context).cancel,
          defaultActionText: l(context).ok,
        ).show(context) ??
        false;
    if (didRequestUnblockUser == true) {
      final result =
          await GetIt.I.get<APIRepository>().unblockUser(userId: userId);
      if (result) {
        await Provider.of<UserController>(context, listen: false).getUser();
        final snackBar = CustomSnackBar(
          icon: const Icon(FontAwesomeIcons.checkCircle, size: 20),
          text: l(context).successfullyUnblocked,
        ).buildSnackBar(context);
        setState(() => ScaffoldMessenger.of(context).showSnackBar(snackBar));
      } else {
        final snackBar = CustomSnackBar(
          icon: const Icon(FontAwesomeIcons.exclamationCircle, size: 20),
          text: l(context).anErrorOccurredWhileUnblocking,
        ).buildSnackBar(context);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  Widget buildBlockedUsers(MyUser user) => FutureBuilder<List<MyUser>?>(
        future: GetIt.I.get<APIRepository>().getBlockedUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final users = snapshot.data!;

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users.elementAt(index);

                return buildCard(user, context);
              },
            );
          } else if (snapshot.hasError) {
            return buildErrorWidget();
          }

          return const Center(child: CircularProgressIndicator());
        },
      );

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserController>(context).user!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l(context).blockedUsers),
      ),
      body: user.blockedUsers!.isEmpty
          ? buildNoBlockedUsersFound(context)
          : buildBlockedUsers(user),
    );
  }
}

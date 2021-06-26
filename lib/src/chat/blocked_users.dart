import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

import '../models/my_user.dart';
import '../models/user_controller_impl.dart';
import '../services/spring_service.dart';
import '../widgets/custom_alert_dialog.dart';

class BlockedUsers extends StatefulWidget {
  const BlockedUsers({Key? key}) : super(key: key);

  static const String routeName = '/blocked-users';

  @override
  _BlockedUsersState createState() => _BlockedUsersState();
}

class _BlockedUsersState extends State<BlockedUsers> {
  Card buildCard(ThemeData theme, MyUser user, BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () {},
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        highlightColor: theme.primaryColorLight.withOpacity(.1),
        splashColor: theme.primaryColorLight.withOpacity(.1),
        child: ListTile(
          leading: CircleAvatar(backgroundImage: NetworkImage(user.avatar!)),
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
              'UNBLOCK',
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
    final bool didRequestUnblockUser = await const CustomAlertDialog(
          title: 'Unblock User',
          content: 'Are you sure you want to unblock this user?',
          cancelActionText: 'Cancel',
          defaultActionText: 'Ok',
        ).show(context) ??
        false;

    if (didRequestUnblockUser == true) {
      final bool result =
          await GetIt.I.get<SpringService>().unblockUser(userUid: userUid);

      if (result) {
        await Provider.of<UserControllerImpl>(context, listen: false).getUser();

        final SnackBar snackBar = SnackBar(
          content: Row(
            children: const <Widget>[
              Icon(FontAwesomeIcons.checkCircle, size: 20.0),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Successfully unblocked this user',
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
            children: const <Widget>[
              Icon(FontAwesomeIcons.exclamationCircle, size: 20.0),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    'An error occurred while unblocking this user',
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
    final ThemeData theme = Theme.of(context);
    final MyUser user = Provider.of<UserControllerImpl>(context).user!;

    Future<void> onRefresh() async {
      await Provider.of<UserControllerImpl>(context, listen: false).getUser();
      setState(() {});

      if (mounted) {
        setState(() {});
      }
    }

    Widget buildNoBlockedUsers() {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: <Widget>[
              Icon(
                LineIcons.user,
                color: theme.primaryColor,
                size: 150.0,
              ),
              const SizedBox(height: 16.0),
              const Text(
                'No blocked users yet',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No blocked users description',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
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

                  return buildCard(theme, user, context);
                },
              ),
            );
          } else if (snapshot.hasError) {
            print(snapshot.error);

            return Text(snapshot.error.toString());
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Users'),
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: user.blockedUsers!.isEmpty
            ? buildNoBlockedUsers()
            : buildBlockedUsers(),
      ),
    );
  }
}

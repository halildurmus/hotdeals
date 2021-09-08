import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

import '../app_localizations.dart';
import '../models/my_user.dart';
import '../models/user_controller_impl.dart';
import '../services/firestore_service.dart';
import '../services/push_notification_service.dart';

typedef Json = Map<String, dynamic>;

class MyBottomNavigationBar extends StatefulWidget {
  const MyBottomNavigationBar(this.activeScreen, this.activeScreenOnChanged,
      {Key? key})
      : super(key: key);

  final int activeScreen;
  final ValueChanged<int> activeScreenOnChanged;

  @override
  _MyBottomNavigationBarState createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  late MyUser? _user;
  bool isLoggedIn = false;
  int unreadMessages = 0;
  int unreadNotifications = 0;
  late int activeScreen;
  late PushNotificationService pushNotificationService;

  @override
  void initState() {
    _user = context.read<UserControllerImpl>().user;
    pushNotificationService = GetIt.I.get<PushNotificationService>();
    activeScreen = widget.activeScreen;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    isLoggedIn = _user != null;

    Widget buildGNav() {
      return Consumer<UserControllerImpl>(
        builder: (BuildContext context, UserControllerImpl mongoUser,
            Widget? child) {
          final MyUser? user = mongoUser.user;
          final bool _isLoggedIn = _user != null;

          return AnimatedBuilder(
            animation: pushNotificationService,
            builder: (BuildContext context, Widget? child) {
              unreadNotifications = pushNotificationService.unreadNotifications;

              return GNav(
                gap: 8,
                color: theme.primaryColorLight,
                activeColor: Colors.white,
                textStyle: textTheme.bodyText2!.copyWith(color: Colors.white),
                tabBackgroundColor: theme.primaryColor,
                padding: const EdgeInsets.all(16),
                tabs: <GButton>[
                  GButton(
                    icon: LineIcons.tag,
                    text: AppLocalizations.of(context)!.deals,
                  ),
                  GButton(
                    icon: LineIcons.compass,
                    text: AppLocalizations.of(context)!.browse,
                  ),
                  GButton(
                    icon: LineIcons.facebookMessenger,
                    leading: widget.activeScreen == 2 || unreadMessages == 0
                        ? null
                        : Badge(
                            badgeColor: theme.primaryColor.withOpacity(.3),
                            elevation: 0,
                            position: BadgePosition.topEnd(top: -12, end: -12),
                            badgeContent: Text(
                              unreadMessages.toString(),
                              style: TextStyle(
                                color: theme.primaryColor.withOpacity(.9),
                              ),
                            ),
                            child: Icon(
                              LineIcons.facebookMessenger,
                              color: theme.primaryColorLight,
                            ),
                          ),
                    text: AppLocalizations.of(context)!.chats,
                  ),
                  GButton(
                    icon: LineIcons.user,
                    leading: _isLoggedIn
                        ? widget.activeScreen == 3 || unreadNotifications == 0
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(user!.avatar!),
                                radius: 12,
                              )
                            : Badge(
                                badgeColor: theme.primaryColor.withOpacity(.3),
                                badgeContent: Text(
                                  unreadNotifications.toString(),
                                  style: TextStyle(
                                    color: theme.primaryColor.withOpacity(.9),
                                  ),
                                ),
                                elevation: 0,
                                position:
                                    BadgePosition.topEnd(top: -12, end: -12),
                                child: CircleAvatar(
                                  radius: 12.0,
                                  backgroundImage: NetworkImage(user!.avatar!),
                                ),
                              )
                        : null,
                    text: AppLocalizations.of(context)!.profile,
                  ),
                ],
                selectedIndex: activeScreen,
                onTabChange: (int index) {
                  setState(() {
                    activeScreen = index;
                    widget.activeScreenOnChanged(activeScreen);
                  });
                },
              );
            },
          );
        },
      );
    }

    Widget buildGNavWithStream() {
      return StreamBuilder<QuerySnapshot<Json>>(
        stream: GetIt.I
            .get<FirestoreService>()
            .messagesStreamByUserUid(userUid: _user!.uid),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Json>> snapshot) {
          if (snapshot.hasData) {
            unreadMessages = 0;
            final List<DocumentSnapshot<Json>> items = snapshot.data!.docs;

            items.removeWhere((DocumentSnapshot<Json> e) =>
                (e.get('latestMessage') as Map<String, dynamic>).isEmpty);

            if (items.isEmpty) {
              return buildGNav();
            }

            for (DocumentSnapshot e in items) {
              final Map<String, dynamic> latestMessage =
                  e.get('latestMessage') as Map<String, dynamic>;

              final String senderId = latestMessage['author']['id'] as String;
              if (senderId != _user?.uid) {
                final bool isRead =
                    (latestMessage['status'] as String) == 'seen';

                if (!isRead) {
                  unreadMessages++;
                }
              }
            }

            return buildGNav();
          }

          return buildGNav();
        },
      );
    }

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: theme.shadowColor.withOpacity(.2),
              blurRadius: 7,
              offset: const Offset(0, -3),
            ),
          ],
          color: theme.backgroundColor,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: isLoggedIn ? buildGNavWithStream() : buildGNav(),
        ),
      ),
    );
  }
}

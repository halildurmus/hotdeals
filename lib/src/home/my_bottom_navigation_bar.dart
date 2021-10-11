import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';

import '../models/my_user.dart';
import '../models/user_controller.dart';
import '../services/firestore_service.dart';
import '../services/push_notification_service.dart';

typedef Json = Map<String, dynamic>;

class MyBottomNavigationBar extends StatefulWidget {
  const MyBottomNavigationBar(
    this.activeScreen,
    this.activeScreenOnChanged, {
    Key? key,
  }) : super(key: key);

  final int activeScreen;
  final ValueChanged<int> activeScreenOnChanged;

  @override
  _MyBottomNavigationBarState createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  MyUser? _user;
  bool isLoggedIn = false;
  int unreadMessages = 0;
  late int activeScreen;
  late final PushNotificationService pushNotificationService;

  @override
  void initState() {
    pushNotificationService = GetIt.I.get<PushNotificationService>();
    activeScreen = widget.activeScreen;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    _user = Provider.of<UserController>(context).user;
    isLoggedIn = _user != null;

    Widget buildGNav() {
      return AnimatedBuilder(
        animation: pushNotificationService,
        builder: (context, child) {
          final unreadNotifications =
              pushNotificationService.unreadNotifications;

          return GNav(
            activeColor: Colors.white,
            color: theme.primaryColorLight,
            gap: 8,
            padding: const EdgeInsets.all(16),
            tabBackgroundColor: theme.primaryColor,
            textStyle: textTheme.bodyText2!.copyWith(color: Colors.white),
            tabs: [
              GButton(
                icon: Icons.local_offer_outlined,
                text: AppLocalizations.of(context)!.deals,
              ),
              GButton(
                icon: Icons.explore_outlined,
                text: AppLocalizations.of(context)!.browse,
              ),
              GButton(
                icon: FontAwesomeIcons.comment,
                iconSize: 20,
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
                          FontAwesomeIcons.comment,
                          color: theme.primaryColorLight,
                          size: 20,
                        ),
                      ),
                text: AppLocalizations.of(context)!.chats,
              ),
              GButton(
                icon: Icons.notifications_outlined,
                leading: isLoggedIn
                    ? widget.activeScreen == 3 || unreadNotifications == 0
                        ? null
                        : Badge(
                            badgeColor: theme.primaryColor.withOpacity(.3),
                            elevation: 0,
                            child: Icon(
                              Icons.notifications_outlined,
                              color: theme.primaryColorLight,
                            ),
                          )
                    : null,
                text: AppLocalizations.of(context)!.notifications,
              ),
              GButton(
                icon: Icons.person_outlined,
                leading: isLoggedIn
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(_user!.avatar!),
                        radius: 12,
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
    }

    Widget buildGNavWithStream() {
      return StreamBuilder<QuerySnapshot<Json>>(
        stream: GetIt.I
            .get<FirestoreService>()
            .messagesStreamByUserUid(userUid: _user!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            unreadMessages = 0;
            final List<DocumentSnapshot<Json>> items = snapshot.data!.docs;
            items.removeWhere((e) => (e.get('latestMessage') as Json).isEmpty);
            if (items.isEmpty) {
              return buildGNav();
            }

            for (DocumentSnapshot e in items) {
              final latestMessage = e.get('latestMessage') as Json;
              final String senderId = latestMessage['author']['id'] as String;
              if (senderId != _user?.uid) {
                final isRead = (latestMessage['status'] as String) == 'seen';
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
          boxShadow: [
            BoxShadow(
              blurRadius: 7,
              color: theme.shadowColor.withOpacity(.2),
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

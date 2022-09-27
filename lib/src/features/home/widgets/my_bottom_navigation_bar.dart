import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../../../helpers/context_extensions.dart';
import '../../auth/presentation/user_controller.dart';
import '../../chat/data/firestore_service.dart';
import '../../notifications/data/push_notification_service.dart';

typedef Json = Map<String, dynamic>;

class MyBottomNavigationBar extends ConsumerStatefulWidget {
  const MyBottomNavigationBar({
    required this.activeScreen,
    required this.onActiveScreenChanged,
    super.key,
  });

  final int activeScreen;
  final ValueChanged<int> onActiveScreenChanged;

  @override
  ConsumerState<MyBottomNavigationBar> createState() =>
      _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends ConsumerState<MyBottomNavigationBar> {
  var unreadMessageCount = 0;
  var activeScreen = 0;

  @override
  void initState() {
    activeScreen = widget.activeScreen;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    if (user == null) return const SizedBox();
    final unreadNotificationCount = ref.watch(pushNotificationServiceProvider
        .select((value) => value.unreadNotifications));
    ref.listen(
      chatMessagesStreamProvider(user.uid),
      (prev, next) {
        if (next.hasValue) {
          final items = next.value!.docs
            ..removeWhere((e) => (e.get('latestMessage') as Json).isEmpty);
          if (items.isEmpty) return;

          unreadMessageCount = 0;
          for (final doc in items) {
            final latestMessage = doc.get('latestMessage') as Json;
            final senderId = latestMessage['author']['id'] as String;
            if (senderId != user.uid) {
              final isRead = (latestMessage['status'] as String) == 'seen';
              if (!isRead) {
                unreadMessageCount++;
              }
            }
          }
          setState(() {});
        }
      },
    );

    return SafeArea(
      child: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 7,
              color: context.t.shadowColor.withOpacity(.2),
              offset: const Offset(0, -3),
            ),
          ],
          color: context.t.backgroundColor,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: GNav(
            activeColor: Colors.white,
            color: context.t.primaryColorLight,
            gap: 8,
            padding: const EdgeInsets.all(16),
            tabBackgroundColor: context.t.primaryColor,
            textStyle:
                context.textTheme.bodyText2!.copyWith(color: Colors.white),
            tabs: [
              GButton(icon: Icons.local_offer_outlined, text: context.l.deals),
              GButton(icon: Icons.explore_outlined, text: context.l.browse),
              GButton(
                icon: FontAwesomeIcons.comment,
                iconSize: 20,
                leading: widget.activeScreen == 2 || unreadMessageCount == 0
                    ? null
                    : Badge(
                        badgeColor: context.t.primaryColor.withOpacity(.3),
                        elevation: 0,
                        position: BadgePosition.topEnd(top: -12, end: -12),
                        badgeContent: Text(
                          unreadMessageCount.toString(),
                          style: TextStyle(
                              color: context.t.primaryColor.withOpacity(.9)),
                        ),
                        child: Icon(
                          FontAwesomeIcons.comment,
                          color: context.t.primaryColorLight,
                          size: 20,
                        ),
                      ),
                text: context.l.chats,
              ),
              GButton(
                icon: Icons.notifications_outlined,
                leading:
                    widget.activeScreen == 3 || unreadNotificationCount == 0
                        ? null
                        : Badge(
                            badgeColor: context.t.primaryColor.withOpacity(.3),
                            elevation: 0,
                            child: Icon(
                              Icons.notifications_outlined,
                              color: context.t.primaryColorLight,
                            ),
                          ),
                text: context.l.notifications,
              ),
              GButton(
                icon: Icons.person_outlined,
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.avatar!),
                  radius: 12,
                ),
                text: context.l.profile,
              ),
            ],
            selectedIndex: activeScreen,
            onTabChange: (index) {
              setState(() {
                activeScreen = index;
                widget.onActiveScreenChanged(activeScreen);
              });
            },
          ),
        ),
      ),
    );
  }
}

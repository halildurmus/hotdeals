import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../browse/presentation/browse_screen.dart';
import '../chat/presentation/chat_screen.dart';
import '../deals/presentation/deals_screen.dart';
import '../notifications/presentation/notifications_controller.dart';
import '../notifications/presentation/notifications_screen.dart';
import '../profile/presentation/my_profile/profile_screen.dart';
import 'home_screen_controller.dart';
import 'widgets/my_bottom_navigation_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const screens = <Widget>[
    DealsScreen(),
    BrowseScreen(),
    ChatScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeScreenIndex = ref.watch(homeScreenControllerProvider);
    final isSelectionModeActive = ref.watch(notificationsControllerProvider
        .select((value) => value.isSelectionModeActive));

    return Scaffold(
      body: screens.elementAt(activeScreenIndex),
      bottomNavigationBar: isSelectionModeActive
          ? const SizedBox()
          : const MyBottomNavigationBar(),
      resizeToAvoidBottomInset: false,
    );
  }
}

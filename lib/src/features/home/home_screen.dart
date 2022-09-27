import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../browse/presentation/browse_screen.dart';
import '../chat/presentation/chat_screen.dart';
import '../deals/presentation/deals_screen.dart';
import '../notifications/presentation/notifications_controller.dart';
import '../notifications/presentation/notifications_screen.dart';
import '../profile/presentation/my_profile/profile_screen.dart';
import 'widgets/my_bottom_navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var activeScreen = 0;

  final screens = const <Widget>[
    DealsScreen(),
    BrowseScreen(),
    ChatScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens.elementAt(activeScreen),
      bottomNavigationBar: Consumer(
        builder: (context, ref, child) {
          final controller = ref.watch(notificationsControllerProvider);
          if (controller.isSelectionModeActive) return const SizedBox();
          return MyBottomNavigationBar(
            activeScreen: activeScreen,
            onActiveScreenChanged: (value) =>
                setState(() => activeScreen = value),
          );
        },
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}

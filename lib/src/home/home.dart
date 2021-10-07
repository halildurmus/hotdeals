import 'package:flutter/material.dart';

import '../browse/browse.dart';
import '../chat/chat_screen.dart';
import '../deal/deals.dart';
import '../profile/profile.dart';
import 'my_bottom_navigation_bar.dart';

typedef Json = Map<String, dynamic>;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int activeScreen = 0;

  final List<Widget> screens = [
    const Deals(),
    const Browse(),
    const ChatScreen(),
    const Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens.elementAt(activeScreen),
      bottomNavigationBar: MyBottomNavigationBar(activeScreen, (int value) {
        setState(() {
          activeScreen = value;
        });
      }),
      resizeToAvoidBottomInset: false,
    );
  }
}

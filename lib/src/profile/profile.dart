import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icon.dart';
import 'package:provider/provider.dart';

import '../app_localizations.dart';
import '../models/my_user.dart';
import '../models/user_controller_impl.dart';
import '../settings/settings.view.dart';
import '../sign_in/sign_in_page.dart';
import '../utils/navigation_util.dart';
import 'avatar_fullscreen.dart';
import 'my_deals.dart';
import 'my_favorites.dart';
import 'my_notifications.dart';
import 'update_profile.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  static const String routeName = '/profile';

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isFavorited = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final MyUser? user = Provider.of<UserControllerImpl>(context).user;

    Widget buildProfileDetails() {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                NavigationUtil.navigate(
                  context,
                  AvatarFullScreen(avatarURL: user!.avatar!),
                );
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(user!.avatar!),
                radius: 50,
              ),
            ),
            const SizedBox(width: 20.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(user.nickname!, style: textTheme.headline6),
                const SizedBox(height: 5.0),
                Text(user.email!, style: textTheme.caption),
                const SizedBox(height: 5.0),
                SizedBox(
                  width: 150.0,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    onPressed: () =>
                        NavigationUtil.navigate(context, const UpdateProfile()),
                    child: Text(AppLocalizations.of(context)!.updateProfile),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget buildTabBar() {
      return Container(
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.light
              ? theme.primaryColor
              : theme.scaffoldBackgroundColor,
        ),
        margin: const EdgeInsets.only(top: 5),
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(bottom: 2.0),
        child: Center(
          child: TabBar(
            isScrollable: true,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
            tabs: <Tab>[
              Tab(text: AppLocalizations.of(context)!.notifications),
              Tab(text: AppLocalizations.of(context)!.posts),
              Tab(text: AppLocalizations.of(context)!.favorites),
            ],
          ),
        ),
      );
    }

    Widget buildTabBarView() {
      return const TabBarView(
        children: <Widget>[
          MyNotifications(),
          MyDeals(),
          MyFavorites(),
        ],
      );
    }

    Widget buildProfile() {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.profile),
          actions: <IconButton>[
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(SettingsView.routeName);
              },
              icon: LineIcon.cog(),
            ),
          ],
        ),
        body: DefaultTabController(
          length: 3,
          child: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool value) {
              return <SliverToBoxAdapter>[
                SliverToBoxAdapter(child: buildProfileDetails()),
                SliverToBoxAdapter(child: buildTabBar()),
              ];
            },
            body: buildTabBarView(),
          ),
        ),
      );
    }

    return user == null ? const SignInPageBuilder() : buildProfile();
  }
}

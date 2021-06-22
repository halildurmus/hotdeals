import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:hotdeals/src/models/my_user.dart';
import 'package:hotdeals/src/services/spring_service.dart';
import 'package:provider/provider.dart';

import '../models/user_controller_impl.dart';
import '../services/auth_service.dart';
import '../widgets/custom_alert_dialog.dart';
import '../widgets/exception_alert_dialog.dart';
import '../widgets/radio_item.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/settings_list_item.dart';
import 'settings_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key, required this.controller}) : super(key: key);

  static const String routeName = '/settings';

  final SettingsController controller;

  String getLanguageName(String languageCode) {
    if (languageCode == 'en_US') {
      return 'English';
    } else {
      return 'Turkish';
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final bool _didRequestSignOut = await const CustomAlertDialog(
          title: 'Are you sure you want to log out?',
          cancelActionText: 'Cancel',
          defaultActionText: 'Logout',
        ).show(context) ??
        false;

    if (_didRequestSignOut) {
      // final MyUser user =
      //     Provider.of<UserControllerImpl>(context, listen: false).user!;
      final String? fcmToken = await FirebaseMessaging.instance.getToken();
      // final int index = user.fcmTokens!.indexOf(fcmToken!);

      // await GetIt.I.get<SpringService>().removeFcmToken(
      //     userId: user.id!, fcmTokenIndex: index, fcmToken: fcmToken);
      await GetIt.I.get<SpringService>().logout(fcmToken: fcmToken!);

      await _signOut(context);

      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final AuthService auth = Provider.of<AuthService>(context, listen: false);
      await auth.signOut();
      Provider.of<UserControllerImpl>(context, listen: false).logout();
    } on PlatformException catch (e) {
      await ExceptionAlertDialog(
        title: 'Logout failed',
        exception: e,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    void changeLanguage() {
      showDialog<void>(
        context: context,
        builder: (BuildContext ctx) {
          return SettingsDialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RadioItem<String>(
                  onChanged: controller.updateLanguage,
                  onTap: () {
                    controller.updateLanguage('en_US');
                  },
                  providerValue: controller.language,
                  radioValue: 'en_US',
                  text: 'English',
                  iconPath: 'assets/icons/en_US.svg',
                ),
                RadioItem<String>(
                  onChanged: controller.updateLanguage,
                  onTap: () {
                    controller.updateLanguage('tr_TR');
                  },
                  providerValue: controller.language,
                  radioValue: 'tr_TR',
                  text: 'Turkish',
                  iconPath: 'assets/icons/tr_TR.svg',
                ),
                const SizedBox(height: 15.0),
                SizedBox(
                  height: 45.0,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Ok',
                      style: textTheme.bodyText1!.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    void changeAppTheme() {
      showDialog<void>(
        context: context,
        builder: (BuildContext ctx) {
          return SettingsDialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RadioItem<ThemeMode>(
                  onChanged: controller.updateThemeMode,
                  onTap: () {
                    controller.updateThemeMode(ThemeMode.system);
                  },
                  providerValue: controller.themeMode,
                  radioValue: ThemeMode.system,
                  icon: Icons.brightness_auto,
                  text: 'System',
                ),
                RadioItem<ThemeMode>(
                  onChanged: controller.updateThemeMode,
                  onTap: () {
                    controller.updateThemeMode(ThemeMode.light);
                  },
                  providerValue: controller.themeMode,
                  radioValue: ThemeMode.light,
                  icon: Icons.light_mode,
                  text: 'Light',
                ),
                RadioItem<ThemeMode>(
                  onChanged: controller.updateThemeMode,
                  onTap: () {
                    controller.updateThemeMode(ThemeMode.dark);
                  },
                  providerValue: controller.themeMode,
                  radioValue: ThemeMode.dark,
                  icon: Icons.dark_mode,
                  text: 'Dark',
                ),
                const SizedBox(height: 15.0),
                SizedBox(
                  height: 45.0,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Ok',
                      style: textTheme.bodyText1!.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: <Widget>[
          SettingsListItem(
            image: SvgPicture.asset('assets/icons/${controller.language}.svg'),
            title: 'Language',
            subtitle: getLanguageName(controller.language),
            onTap: changeLanguage,
          ),
          SettingsListItem(
            icon: Icons.settings_brightness,
            title: 'Theme',
            subtitle: describeEnum(controller.themeMode)[0].toUpperCase() +
                describeEnum(controller.themeMode).substring(1),
            onTap: changeAppTheme,
          ),
          SettingsListItem(
            hasNavigation: false,
            icon: Icons.cancel,
            title: 'Logout',
            onTap: () => _confirmSignOut(context),
          ),
        ],
      ),
    );
  }
}

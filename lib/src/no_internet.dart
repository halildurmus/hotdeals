import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';

import 'services/connection_service.dart';

class NoInternet extends StatefulWidget {
  const NoInternet({Key? key}) : super(key: key);

  @override
  _NoInternetState createState() => _NoInternetState();
}

class _NoInternetState extends State<NoInternet> {
  late StreamSubscription<void> connection;
  bool isConnected = false;

  @override
  void initState() {
    final ConnectionService connectionService =
        GetIt.I.get<ConnectionService>();
    connection = connectionService.connectionChange.listen((bool event) {
      setState(() {
        isConnected = event;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    connection.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    Widget buildHeader() {
      return Positioned(
        height: 32,
        left: 0,
        right: 0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          color:
              isConnected ? const Color(0xFF00EE44) : const Color(0xFFEE4400),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isConnected
                    ? AppLocalizations.of(context)!.online
                    : AppLocalizations.of(context)!.offline,
                style: textTheme.bodyText2!.copyWith(color: Colors.white),
              ),
              if (!isConnected) const SizedBox(width: 8),
              if (!isConnected)
                SizedBox.fromSize(
                  size: const Size(12, 12),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    Widget buildBody() {
      return Center(
        child: isConnected
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.wifi,
                    color: theme.primaryColorLight,
                    size: 40,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)!.checkYourInternet,
                    style: textTheme.bodyText2!.copyWith(fontSize: 15),
                  ),
                ],
              ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.appTitle),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          buildHeader(),
          buildBody(),
        ],
      ),
    );
  }
}

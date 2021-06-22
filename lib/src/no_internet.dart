import 'dart:async';

import 'package:flutter/material.dart';
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
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

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
            children: <Widget>[
              Text(
                isConnected ? 'ONLINE' : 'OFFLINE',
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
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.wifi,
                    color: theme.primaryColorLight,
                    size: 40,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Please check your internet connection',
                    style: textTheme.bodyText2!.copyWith(fontSize: 15),
                  ),
                ],
              ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('hotdeals'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          buildHeader(),
          buildBody(),
        ],
      ),
    );
  }
}

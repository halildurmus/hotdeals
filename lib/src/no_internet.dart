import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';

import 'services/connection_service.dart';
import 'utils/localization_util.dart';

class NoInternet extends StatefulWidget {
  const NoInternet({Key? key}) : super(key: key);

  @override
  _NoInternetState createState() => _NoInternetState();
}

class _NoInternetState extends State<NoInternet> {
  late final StreamSubscription<bool> _connection;
  bool _isConnected = false;

  @override
  void initState() {
    final ConnectionService connectionService =
        GetIt.I.get<ConnectionService>();
    _connection = connectionService.connectionChange.listen((bool isConnected) {
      _isConnected = isConnected;
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _connection.cancel();
    super.dispose();
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
              _isConnected ? const Color(0xFF00EE44) : const Color(0xFFEE4400),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isConnected ? l(context).online : l(context).offline,
                style: textTheme.bodyText2!.copyWith(color: Colors.white),
              ),
              if (!_isConnected) const SizedBox(width: 8),
              if (!_isConnected)
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
        child: _isConnected
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
                    l(context).checkYourInternet,
                    style: textTheme.bodyText2!.copyWith(fontSize: 15),
                  ),
                ],
              ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(l(context).appTitle),
      ),
      body: Stack(fit: StackFit.expand, children: [buildHeader(), buildBody()]),
    );
  }
}

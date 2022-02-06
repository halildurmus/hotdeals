import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';

import 'constants.dart';
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
    final connectionService = GetIt.I.get<ConnectionService>();
    super.initState();
    _connection = connectionService.connectionChange
        .listen((isConnected) => setState(() => _isConnected = isConnected));
  }

  @override
  void dispose() {
    _connection.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(appTitle),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            _Header(isConnected: _isConnected),
            _Body(isConnected: _isConnected),
          ],
        ),
      );
}

class _Header extends StatelessWidget {
  const _Header({required this.isConnected, Key? key}) : super(key: key);

  final bool isConnected;

  @override
  Widget build(BuildContext context) => Positioned(
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
                isConnected ? l(context).online : l(context).offline,
                style: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .copyWith(color: Colors.white),
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

class _Body extends StatelessWidget {
  const _Body({required this.isConnected, Key? key}) : super(key: key);

  final bool isConnected;

  @override
  Widget build(BuildContext context) => Center(
        child: isConnected
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.wifi,
                    color: Theme.of(context).primaryColorLight,
                    size: 40,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l(context).checkYourInternet,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2!
                        .copyWith(fontSize: 15),
                  ),
                ],
              ),
      );
}

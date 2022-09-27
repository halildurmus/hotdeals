import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../core/connection_service.dart';
import '../helpers/context_extensions.dart';
import '../l10n/localization_constants.dart';

class NoInternetScreen extends ConsumerStatefulWidget {
  const NoInternetScreen({super.key});

  @override
  ConsumerState<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends ConsumerState<NoInternetScreen> {
  late final StreamSubscription<bool> _connection;
  bool _isConnected = false;

  @override
  void initState() {
    final connectionService = ref.read(connectionServiceProvider);
    super.initState();
    _connection = connectionService.connectionChange.listen((isConnected) {
      setState(() {
        _isConnected = isConnected;
      });
    });
  }

  @override
  void dispose() {
    _connection.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(appTitle),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            height: 32,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              color: _isConnected
                  ? const Color(0xFF00EE44)
                  : const Color(0xFFEE4400),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isConnected ? context.l.online : context.l.offline,
                    style: context.textTheme.bodyText2!
                        .copyWith(color: Colors.white),
                  ),
                  if (!_isConnected) ...[
                    const SizedBox(width: 8),
                    SizedBox.fromSize(
                      size: const Size.square(12),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Center(
            child: _isConnected
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.wifi,
                        color: context.t.primaryColorLight,
                        size: 40,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        context.l.checkYourInternet,
                        style:
                            context.textTheme.bodyText2!.copyWith(fontSize: 15),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

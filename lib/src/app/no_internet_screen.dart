import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../common_widgets/error_indicator.dart';
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
        title: const Text(appTitle),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedContainer(
            color: _isConnected
                ? const Color(0xFF00EE44)
                : const Color(0xFFEE4400),
            duration: const Duration(milliseconds: 300),
            height: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isConnected)
                  SizedBox.fromSize(
                    size: const Size.square(12),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    _isConnected ? context.l.online : context.l.offline,
                    style: context.textTheme.bodyText2!
                        .copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: Center(
              child: _isConnected
                  ? const CircularProgressIndicator()
                  : ErrorIndicator(
                      icon: FontAwesomeIcons.wifi,
                      title: context.l.checkYourInternet,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

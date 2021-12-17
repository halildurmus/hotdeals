import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hotdeals/src/constants.dart';
import 'package:loggy/loggy.dart' show NetworkLoggy;

import '../services/connection_service.dart';
import '../utils/offline_builder_util.dart';

const Duration kOfflineDebounceDuration = Duration(seconds: 3);

typedef ValueWidgetBuilder<T> = Widget Function(
    BuildContext context, T value, Widget child);

class OfflineBuilder extends StatefulWidget {
  const OfflineBuilder({
    Key? key,
    required this.connectivityBuilder,
    required this.connectionService,
    this.debounceDuration = kOfflineDebounceDuration,
    this.builder,
    this.child,
    this.errorBuilder,
  })  : assert(
            !(builder is WidgetBuilder && child is Widget) &&
                !(builder == null && child == null),
            'You should specify either a builder or a child'),
        super(key: key);

  /// Override connectivity service used for testing
  final ConnectionService connectionService;

  /// Debounce duration from epileptic network situations
  final Duration debounceDuration;

  /// Used for building the Offline and/or Online UI
  final ValueWidgetBuilder<bool> connectivityBuilder;

  /// Used for building the child widget
  final WidgetBuilder? builder;

  /// The widget below this widget in the tree.
  final Widget? child;

  /// Used for building the error widget in case of any platform errors
  final WidgetBuilder? errorBuilder;

  @override
  OfflineBuilderState createState() => OfflineBuilderState();
}

class OfflineBuilderState extends State<OfflineBuilder> with NetworkLoggy {
  late Stream<bool> _connectivityStream;

  @override
  void initState() {
    super.initState();

    _connectivityStream =
        Stream<bool>.fromFuture(widget.connectionService.checkConnection())
            .asyncExpand((bool data) => widget
                .connectionService.connectionChange
                .transform(startsWith(data)))
            .transform(debounce(widget.debounceDuration));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _connectivityStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData && !snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(appTitle),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          loggy.error(snapshot.error, snapshot.error);
          if (widget.errorBuilder != null) {
            return widget.errorBuilder!(context);
          }

          throw _OfflineBuilderError(snapshot.error!);
        }

        return widget.connectivityBuilder(
          context,
          snapshot.data!,
          widget.child ?? widget.builder!(context),
        );
      },
    );
  }
}

class _OfflineBuilderError extends Error {
  _OfflineBuilderError(this.error);

  final Object error;

  @override
  String toString() => error.toString();
}

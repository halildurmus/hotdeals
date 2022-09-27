import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loggy/loggy.dart' show NetworkLoggy;

import '../core/connection_service.dart';
import '../l10n/localization_constants.dart';

typedef ValueWidgetBuilder<T> = Widget Function(
    BuildContext context, T value, Widget child);

class OfflineBuilder extends StatefulWidget {
  const OfflineBuilder({
    required this.connectivityBuilder,
    required this.connectionService,
    this.debounceDuration = const Duration(seconds: 3),
    this.builder,
    this.child,
    this.errorBuilder,
    super.key,
  }) : assert(
            !(builder is WidgetBuilder && child is Widget) &&
                !(builder == null && child == null),
            'You need to provide either a builder or a child');

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
            .asyncExpand((data) => widget.connectionService.connectionChange
                .transform(_startsWith(data)))
            .transform(_debounce(widget.debounceDuration));
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

StreamTransformer<bool, bool> _debounce(Duration debounceDuration) {
  Timer? debounceTimer;
  var seenFirstData = false;

  return StreamTransformer.fromHandlers(
    handleData: (data, sink) {
      if (seenFirstData) {
        debounceTimer?.cancel();
        debounceTimer = Timer(debounceDuration, () => sink.add(data));
      } else {
        sink.add(data);
        seenFirstData = true;
      }
    },
    handleDone: (sink) {
      debounceTimer?.cancel();
      sink.close();
    },
  );
}

StreamTransformer<bool, bool> _startsWith(bool data) =>
    StreamTransformer<bool, bool>(
      (input, cancelOnError) {
        StreamController<bool>? controller;
        late StreamSubscription<bool> subscription;

        controller = StreamController<bool>(
          sync: true,
          onListen: () => controller?.add(data),
          onPause: ([resumeSignal]) => subscription.pause(resumeSignal),
          onResume: () => subscription.resume(),
          onCancel: () => subscription.cancel(),
        );

        subscription = input.listen(
          controller.add,
          onError: controller.addError,
          onDone: controller.close,
          cancelOnError: cancelOnError,
        );

        return controller.stream.listen(null);
      },
    );

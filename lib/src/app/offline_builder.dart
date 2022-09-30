import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loggy/loggy.dart' show NetworkLoggy;

import '../core/connection_service.dart';
import '../l10n/localization_constants.dart';
import 'no_internet_screen.dart';

class OfflineBuilder extends ConsumerStatefulWidget {
  const OfflineBuilder({required this.child, super.key});

  /// The widget below this widget in the tree.
  final Widget? child;

  @override
  ConsumerState<OfflineBuilder> createState() => _OfflineBuilderState();
}

class _OfflineBuilderState extends ConsumerState<OfflineBuilder>
    with NetworkLoggy {
  /// Debounce duration from epileptic network situations
  static const debounceDuration = Duration(seconds: 3);

  late Stream<bool> _connectivityStream;

  @override
  void initState() {
    super.initState();
    _connectivityStream = Stream<bool>.fromFuture(
            ref.read(connectionServiceProvider).checkConnection())
        .asyncExpand((data) => ref
            .read(connectionServiceProvider)
            .connectionChange
            .transform(_startsWith(data)))
        .transform(_debounce(debounceDuration));
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
          return const NoInternetScreen();
        }

        final isConnected = snapshot.data!;
        return isConnected
            ? widget.child ?? const SizedBox()
            : const NoInternetScreen();
      },
    );
  }
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

StreamTransformer<bool, bool> _startsWith(bool data) {
  return StreamTransformer<bool, bool>(
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
}

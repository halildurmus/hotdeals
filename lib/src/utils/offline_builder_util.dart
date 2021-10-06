import 'dart:async';

StreamTransformer<bool, bool> debounce(Duration debounceDuration) {
  bool _seenFirstData = false;
  Timer? _debounceTimer;

  return StreamTransformer<bool, bool>.fromHandlers(
    handleData: (bool data, EventSink<bool> sink) {
      if (_seenFirstData) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(debounceDuration, () => sink.add(data));
      } else {
        sink.add(data);
        _seenFirstData = true;
      }
    },
    handleDone: (EventSink<bool> sink) {
      _debounceTimer?.cancel();
      sink.close();
    },
  );
}

StreamTransformer<bool, bool> startsWith(bool data) {
  return StreamTransformer<bool, bool>(
    (Stream<bool> input, bool cancelOnError) {
      StreamController<bool>? controller;
      late StreamSubscription<bool> subscription;

      controller = StreamController<bool>(
        sync: true,
        onListen: () => controller?.add(data),
        onPause: ([Future<dynamic>? resumeSignal]) =>
            subscription.pause(resumeSignal),
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

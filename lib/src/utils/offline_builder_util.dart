import 'dart:async';

StreamTransformer<bool, bool> debounce(Duration debounceDuration) {
  Timer? _debounceTimer;
  bool seenFirstData = false;

  return StreamTransformer<bool, bool>.fromHandlers(
    handleData: (data, sink) {
      if (seenFirstData) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(debounceDuration, () => sink.add(data));
      } else {
        sink.add(data);
        seenFirstData = true;
      }
    },
    handleDone: (sink) {
      _debounceTimer?.cancel();
      sink.close();
    },
  );
}

StreamTransformer<bool, bool> startsWith(bool data) {
  return StreamTransformer<bool, bool>(
    (input, cancelOnError) {
      StreamController<bool>? controller;
      late StreamSubscription<bool> subscription;

      controller = StreamController<bool>(
        sync: true,
        onListen: () => controller?.add(data),
        onPause: ([resumeSignal]) =>
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

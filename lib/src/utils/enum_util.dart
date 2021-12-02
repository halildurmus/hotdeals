// TODO(halildurmus): Remove this once Dart 2.15 is released.
extension EnumName on Enum {
  /// Returns the enum name.
  // ignore: recursive_getters
  String get name => toString().split('.').last;
}

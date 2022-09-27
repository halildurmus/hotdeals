// Since enum members in Java are defined as all caps, we need to change Dart
// enum names to all cap when intereacting with the backend.
extension ConvertEnumNameToAllCaps on Enum {
  /// The name of the enum value in all caps.
  String get javaName => name.toUpperCase();
}

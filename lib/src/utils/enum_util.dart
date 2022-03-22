// Since enum members in Java are defined as all caps, when interacting with
// the backend we need to change dart enum names to all caps.
extension ConverEnumNameToAllCaps on Enum {
  /// The name of the enum value in all caps.
  String get javaName => name.toUpperCase();
}

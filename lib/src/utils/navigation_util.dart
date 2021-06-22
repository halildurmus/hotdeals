import 'package:flutter/material.dart';

/// A static class that contains useful functions for navigation.
class NavigationUtil {
  /// Navigates to the given route, with the given positional parameters named
  /// [context] and [widget].
  static Future<void> navigate(BuildContext context, Widget widget) =>
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: (BuildContext context) => widget),
      );
}

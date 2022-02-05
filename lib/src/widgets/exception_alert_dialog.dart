import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants.dart';
import 'custom_alert_dialog.dart';

class ExceptionAlertDialog extends CustomAlertDialog {
  ExceptionAlertDialog({
    required PlatformException exception,
    required String title,
    Key? key,
  }) : super(
          key: key,
          content: message(exception) ?? '',
          title: title,
        );

  static String? message(PlatformException exception) {
    if (exception.message == 'FIRFirestoreErrorDomain') {
      // "Missing or insufficient permissions" error
      if (exception.code == 'Code 7') {
        return 'This operation could not be completed due to a server error';
      }

      return exception.details as String;
    }

    return errors[exception.code] ?? exception.message;
  }
}

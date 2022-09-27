import 'package:flutter/services.dart';

import '../exceptions/error_constants.dart';
import 'custom_alert_dialog.dart';

class ExceptionAlertDialog extends CustomAlertDialog {
  ExceptionAlertDialog({
    required PlatformException exception,
    required super.title,
    super.key,
  }) : super(content: message(exception) ?? '');

  static String? message(PlatformException exception) {
    if (exception.message == 'FIRFirestoreErrorDomain') {
      // "Missing or insufficient permissions" error
      if (exception.code == 'Code 7') {
        return 'This operation could not be completed due to a server error';
      }

      return exception.details as String;
    }

    return signInErrors[exception.code] ?? exception.message;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'custom_alert_dialog.dart';

class ExceptionAlertDialog extends CustomAlertDialog {
  ExceptionAlertDialog({
    Key? key,
    required String title,
    required PlatformException exception,
  }) : super(
          key: key,
          title: title,
          content: message(exception) ?? '',
        );

  static String? message(PlatformException exception) {
    if (exception.message == 'FIRFirestoreErrorDomain') {
      // "Missing or insufficient permissions" error
      if (exception.code == 'Code 7') {
        return 'This operation could not be completed due to a server error';
      }

      return exception.details as String;
    } else if (exception.code == 'MONGODB_CREATE_USER_ERROR') {
      return 'An error occurred. Please try again later.';
    }

    return errors[exception.code] ?? exception.message;
  }

  // NOTE: The full list of FirebaseAuth errors is stored here:
  // https://github.com/firebase/firebase-ios-sdk/blob/2e77efd786e4895d50c3788371ec15980c729053/Firebase/Auth/Source/FIRAuthErrorUtils.m
  // These are just the most relevant for email & password sign in:
  static Map<String, String> errors = <String, String>{
    'ERROR_WEAK_PASSWORD': 'The password must be 8 characters long or more.',
    'ERROR_INVALID_CREDENTIAL': 'The email address is badly formatted.',
    'ERROR_EMAIL_ALREADY_IN_USE':
        'The email address is already registered. Sign in instead?',
    'ERROR_INVALID_EMAIL': 'The email address is badly formatted.',
    'ERROR_WRONG_PASSWORD': 'The password is incorrect. Please try again.',
    'ERROR_USER_NOT_FOUND':
        'The email address is not registered. Need an account?',
    'ERROR_TOO_MANY_REQUESTS':
        'We have blocked all requests from this device due to unusual activity. Try again later.',
    'ERROR_OPERATION_NOT_ALLOWED':
        'This sign in method is not allowed. Please contact support.',
  };
}

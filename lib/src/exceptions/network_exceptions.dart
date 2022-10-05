import 'dart:io';

import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_exceptions.freezed.dart';

@freezed
class NetworkExceptions with _$NetworkExceptions {
  const factory NetworkExceptions.badRequest(String reason) = BadRequest;
  const factory NetworkExceptions.conflict() = Conflict;
  const factory NetworkExceptions.defaultError(String error) = DefaultError;
  const factory NetworkExceptions.formatException() = FormatException;
  const factory NetworkExceptions.internalServerError() = InternalServerError;
  const factory NetworkExceptions.methodNotAllowed() = MethodNotAllowed;
  const factory NetworkExceptions.noInternetConnection() = NoInternetConnection;
  const factory NetworkExceptions.notAcceptable() = NotAcceptable;
  const factory NetworkExceptions.notFound(String reason) = NotFound;
  const factory NetworkExceptions.notImplemented() = NotImplemented;
  const factory NetworkExceptions.requestCancelled() = RequestCancelled;
  const factory NetworkExceptions.requestTimeout() = RequestTimeout;
  const factory NetworkExceptions.sendTimeout() = SendTimeout;
  const factory NetworkExceptions.serviceUnavailable() = ServiceUnavailable;
  const factory NetworkExceptions.unableToProcess() = UnableToProcess;
  const factory NetworkExceptions.unauthorizedRequest(String reason) =
      UnauthorizedRequest;
  const factory NetworkExceptions.unexpectedError() = UnexpectedError;

  static NetworkExceptions _handleResponse(Response response) {
    final statusCode = response.statusCode;
    switch (statusCode) {
      case 400:
        return NetworkExceptions.badRequest(
            response.data['error']['message'] ?? 'Bad Request');
      case 401:
      case 403:
        return NetworkExceptions.unauthorizedRequest(
          response.statusMessage ?? 'Unauthorized',
        );
      case 404:
        return NetworkExceptions.notFound(
          response.statusMessage ?? 'Unauthorized',
        );
      case 409:
        return const NetworkExceptions.conflict();
      case 408:
        return const NetworkExceptions.requestTimeout();
      case 500:
        return const NetworkExceptions.internalServerError();
      case 503:
        return const NetworkExceptions.serviceUnavailable();
      default:
        return NetworkExceptions.defaultError(
          'Received invalid status code: $statusCode',
        );
    }
  }

  static NetworkExceptions getDioException(error) {
    if (error is SocketException) {
      return const NetworkExceptions.noInternetConnection();
    }

    if (error is! Exception || error is! DioError) {
      return const NetworkExceptions.unexpectedError();
    }

    switch (error.type) {
      case DioErrorType.cancel:
        return const NetworkExceptions.requestCancelled();
      case DioErrorType.connectTimeout:
        return const NetworkExceptions.requestTimeout();
      case DioErrorType.other:
        return const NetworkExceptions.noInternetConnection();
      case DioErrorType.receiveTimeout:
        return const NetworkExceptions.sendTimeout();
      case DioErrorType.response:
        return NetworkExceptions._handleResponse(error.response!);
      case DioErrorType.sendTimeout:
        return const NetworkExceptions.sendTimeout();
    }
  }

  static String getErrorMessage(NetworkExceptions networkExceptions) {
    return networkExceptions.when(
      badRequest: (reason) => reason,
      conflict: () => 'Conflict',
      defaultError: (error) => error,
      formatException: () => 'Format Exception',
      internalServerError: () => 'Internal Server Error',
      methodNotAllowed: () => 'Method Not Allowed',
      noInternetConnection: () => 'No Internet Connection',
      notAcceptable: () => 'Not Acceptable',
      notFound: (reason) => reason,
      notImplemented: () => 'Not Implemented',
      requestCancelled: () => 'Request Cancelled',
      requestTimeout: () => 'Request Timeout',
      sendTimeout: () => 'Send Timeout',
      serviceUnavailable: () => 'Service Unavailable',
      unableToProcess: () => 'Unable To Process',
      unauthorizedRequest: (error) => error,
      unexpectedError: () => 'Unexpected Error',
    );
  }
}

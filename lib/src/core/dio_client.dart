import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loggy/loggy.dart';

import '../config/environment.dart';
import '../exceptions/network_exceptions.dart';
import '../logging/dio_log_interceptor.dart';
import 'auth_interceptor.dart';

final dioProvider = Provider<DioClient>(
  (ref) {
    final baseUrl = ref.watch(environmentConfigProvider).apiBaseUrl;
    final dio = Dio()..options.baseUrl = baseUrl;
    ref.onDispose(dio.close);
    return DioClient(dio, ref);
  },
  name: 'DioProvider',
);

const _defaultConnectTimeout = 5 * Duration.millisecondsPerSecond; // 5 seconds
const _defaultReceiveTimeout = 3 * Duration.millisecondsPerSecond; // 3 seconds

class DioClient with NetworkLoggy {
  DioClient(this._dio, Ref ref) {
    _dio
      ..options.connectTimeout = _defaultConnectTimeout
      ..options.receiveTimeout = _defaultReceiveTimeout;

    if (kDebugMode) {
      _dio.interceptors.add(dioLogInterceptor);
    }
    _dio.interceptors.add(AuthInterceptor(_dio, ref));
  }

  final Dio _dio;

  String get baseUrl => _dio.options.baseUrl;

  /// Wrapper function for `HTTP` requests that uses try-catch block to reduce
  /// boilerplate.
  Future<Response<T>> _wrap<T>(Future<Response<T>> Function() request) async {
    try {
      return await request();
    } catch (e) {
      loggy.error(e);
      throw NetworkExceptions.getDioException(e);
    }
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) =>
      _wrap(
        () => _dio.get<T>(
          path,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
        ),
      );

  Future<Response<T>> post<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      _wrap(
        () => _dio.post(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        ),
      );

  Future<Response<T>> patch<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      _wrap(
        () => _dio.patch(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options ?? Options()
            ..contentType = 'application/json-patch+json',
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        ),
      );

  Future<Response<T>> put<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      _wrap(
        () => _dio.put(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        ),
      );

  Future<Response<T>> delete<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _wrap(
        () => _dio.delete(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        ),
      );
}

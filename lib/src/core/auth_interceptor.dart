import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/data/firebase_auth_repository.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this.dio, this.ref);

  final Dio dio;
  final Ref ref;

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = ref.read(idTokenProvider);
    if (token != null) {
      options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    return super.onRequest(options, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.type == DioErrorType.response && err.response?.statusCode == 401) {
      final token = await ref.read(authApiProvider).currentUser!.getIdToken();
      err.requestOptions.headers['Authorization'] = 'Bearer $token';
      // create request with new access token
      final opts = Options(
        method: err.requestOptions.method,
        headers: err.requestOptions.headers,
      );
      final clonedReq = await dio.request(
        err.requestOptions.path,
        options: opts,
        data: err.requestOptions.data,
        queryParameters: err.requestOptions.queryParameters,
      );
      return handler.resolve(clonedReq);
    }
    return super.onError(err, handler);
  }
}

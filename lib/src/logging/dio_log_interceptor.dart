import 'package:dio/dio.dart';

final dioLogInterceptor = LogInterceptor(
  error: true,
  // logPrint: loggy.debug,
  responseHeader: false,
  responseBody: true,
  request: false,
  requestBody: false,
  requestHeader: false,
);

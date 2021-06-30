import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart';

import 'http_service.dart';

const Duration _timeout = Duration(seconds: 5);
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

class HttpServiceImpl implements HttpService {
  /// Creates an instance of [HttpServiceImpl] with given HTTP [client].
  /// If no [client] is given, automatically initializes a new HTTP [client].
  factory HttpServiceImpl({Client? client}) {
    if (client == null) {
      return HttpServiceImpl._privateConstructor(Client());
    }

    return HttpServiceImpl._privateConstructor(client);
  }

  HttpServiceImpl._privateConstructor(Client client) {
    _client = client;
  }

  late Client _client;

  @override
  Future<Response> delete(String url) async {
    final String idToken = await _firebaseAuth.currentUser!.getIdToken();

    Response response;
    try {
      response = await _client.delete(
        Uri.parse(url),
        headers: <String, String>{
          'Accept': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json; charset=utf-8',
        },
      ).timeout(_timeout, onTimeout: () {
        throw Exception('Server timeout');
      });
    } on Exception catch (e) {
      print(e);
      throw Exception(e);
    }

    return response;
  }

  @override
  Future<Response> get(String url, {bool auth = true}) async {
    String? idToken;
    if (auth) {
      idToken = await _firebaseAuth.currentUser!.getIdToken();
    }

    Response response;
    try {
      response = await _client.get(
        Uri.parse(url),
        headers: <String, String>{
          'Accept': 'application/json; charset=utf-8',
          if (auth) 'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json; charset=utf-8',
        },
      ).timeout(_timeout, onTimeout: () {
        throw Exception('Server timeout');
      });
    } on Exception catch (e) {
      print(e);
      throw Exception(e);
    }

    return response;
  }

  @override
  Future<Response> patch(String url, List<Json>? data) async {
    final String idToken = await _firebaseAuth.currentUser!.getIdToken();
    data ??= [<String, dynamic>{}];

    Response response;
    try {
      response = await _client
          .patch(
        Uri.parse(url),
        headers: <String, String>{
          'Accept': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json-patch+json',
        },
        body: jsonEncode(data),
      )
          .timeout(_timeout, onTimeout: () {
        throw Exception('Server timeout');
      });
    } on Exception catch (e) {
      print(e);
      throw Exception(e);
    }

    return response;
  }

  @override
  Future<Response> post(String url, Json? data, {bool auth = true}) async {
    String? idToken;
    if (auth) {
      idToken = await _firebaseAuth.currentUser!.getIdToken();
    }
    data ??= <String, dynamic>{};

    Response response;
    try {
      response = await _client
          .post(
        Uri.parse(url),
        headers: <String, String>{
          'Accept': 'application/json; charset=utf-8',
          if (auth) 'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: jsonEncode(data),
      )
          .timeout(_timeout, onTimeout: () {
        throw Exception('Server timeout');
      });
    } on Exception catch (e) {
      print(e);
      throw Exception(e);
    }

    return response;
  }
}

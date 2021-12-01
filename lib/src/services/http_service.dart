import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart';

typedef Json = Map<String, dynamic>;

const Duration _timeoutDuration = Duration(seconds: 5);
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

class HttpService {
  /// Creates an instance of [HttpService] with given HTTP [client].
  /// If no [client] is given, automatically initializes a new HTTP [client].
  factory HttpService({Client? client}) {
    if (client == null) {
      return HttpService._privateConstructor(Client());
    }

    return HttpService._privateConstructor(client);
  }

  HttpService._privateConstructor(Client client) {
    _client = client;
  }

  late Client _client;

  Future<Response> delete(String url, [Json? data]) async {
    final String idToken = await _firebaseAuth.currentUser!.getIdToken();

    Response response;
    try {
      response = await _client
          .delete(
            Uri.parse(url),
            headers: <String, String>{
              'Accept': 'application/json; charset=utf-8',
              'Authorization': 'Bearer $idToken',
              'Content-Type': 'application/json; charset=utf-8',
            },
            body: data != null ? jsonEncode(data) : null,
          )
          .timeout(
            _timeoutDuration,
            onTimeout: () => throw Exception('Server timeout'),
          );
    } on Exception catch (e) {
      throw Exception(e);
    }

    return response;
  }

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
      ).timeout(
        _timeoutDuration,
        onTimeout: () => throw Exception('Server timeout'),
      );
    } on Exception catch (e) {
      throw Exception(e);
    }

    return response;
  }

  Future<Response> patch(String url, List<Json> data) async {
    final String idToken = await _firebaseAuth.currentUser!.getIdToken();

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
          .timeout(
            _timeoutDuration,
            onTimeout: () => throw Exception('Server timeout'),
          );
    } on Exception catch (e) {
      throw Exception(e);
    }

    return response;
  }

  Future<Response> post(String url, Json? data, {bool auth = true}) async {
    String? idToken;
    if (auth) {
      idToken = await _firebaseAuth.currentUser!.getIdToken();
    }

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
            body: data != null ? jsonEncode(data) : null,
          )
          .timeout(
            _timeoutDuration,
            onTimeout: () => throw Exception('Server timeout'),
          );
    } on Exception catch (e) {
      throw Exception(e);
    }

    return response;
  }

  Future<Response> put(String url, [Json? data]) async {
    final String idToken = await _firebaseAuth.currentUser!.getIdToken();
    data ??= <String, dynamic>{};

    Response response;
    try {
      response = await _client
          .put(
            Uri.parse(url),
            headers: <String, String>{
              'Accept': 'application/json; charset=utf-8',
              'Authorization': 'Bearer $idToken',
              'Content-Type': 'application/json; charset=utf-8',
            },
            body: jsonEncode(data),
          )
          .timeout(
            _timeoutDuration,
            onTimeout: () => throw Exception('Server timeout'),
          );
    } on Exception catch (e) {
      throw Exception(e);
    }

    return response;
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart';

typedef Json = Map<String, dynamic>;

final _firebaseAuth = FirebaseAuth.instance;
const _headers = <String, String>{
  'Accept': 'application/json; charset=utf-8',
  'Content-Type': 'application/json; charset=utf-8',
};
const _timeoutDuration = Duration(seconds: 5);

/// A class that exposes `HTTP` methods to interact with the Backend.
class HttpService {
  /// Creates an instance of [HttpService] with given `HTTP` [client].
  /// If no [client] is given, creates a default one.
  factory HttpService({Client? client}) =>
      HttpService._privateConstructor(client ?? Client());

  HttpService._privateConstructor(Client client) {
    _client = client;
  }

  late final Client _client;

  // Wrapper function for HTTP requests to reduce boilerplate.
  Future<Response> _request(Future<Response> Function() fn) async {
    try {
      return fn().timeout(
        _timeoutDuration,
        onTimeout: () => throw TimeoutException(null, _timeoutDuration),
      );
    } on SocketException catch (e) {
      throw SocketException(e.toString());
    } on Exception {
      rethrow;
    }
  }

  Future<Response> get(String url, {bool auth = true}) async {
    String? idToken;
    if (auth) {
      idToken = await _firebaseAuth.currentUser!.getIdToken();
    }

    return _request(() => _client.get(
          Uri.parse(url),
          headers: <String, String>{
            if (auth) 'Authorization': 'Bearer $idToken',
            ..._headers,
          },
        ));
  }

  Future<Response> patch(String url, List<Json> data) async {
    final idToken = await _firebaseAuth.currentUser!.getIdToken();

    return _request(() => _client.patch(
          Uri.parse(url),
          headers: <String, String>{
            'Authorization': 'Bearer $idToken',
            _headers.keys.first: _headers.values.first,
            'Content-Type': 'application/json-patch+json',
          },
          body: jsonEncode(data),
        ));
  }

  Future<Response> post(String url, Json? data, {bool auth = true}) async {
    String? idToken;
    if (auth) {
      idToken = await _firebaseAuth.currentUser!.getIdToken();
    }

    return _request(() => _client.post(
          Uri.parse(url),
          headers: <String, String>{
            if (auth) 'Authorization': 'Bearer $idToken',
            ..._headers,
          },
          body: data != null ? jsonEncode(data) : null,
        ));
  }

  Future<Response> put(String url, [Json? data]) async {
    final idToken = await _firebaseAuth.currentUser!.getIdToken();
    data ??= <String, dynamic>{};

    return _request(() => _client.put(
          Uri.parse(url),
          headers: <String, String>{
            'Authorization': 'Bearer $idToken',
            ..._headers,
          },
          body: jsonEncode(data),
        ));
  }

  Future<Response> delete(String url, [Json? data]) async {
    final idToken = await _firebaseAuth.currentUser!.getIdToken();

    return _request(() => _client.delete(
          Uri.parse(url),
          headers: <String, String>{
            'Authorization': 'Bearer $idToken',
            ..._headers,
          },
          body: data != null ? jsonEncode(data) : null,
        ));
  }
}

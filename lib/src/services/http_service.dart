import 'package:http/http.dart';

typedef Json = Map<String, dynamic>;

abstract class HttpService {
  Future<Response> delete(String url);

  Future<Response> get(String url, {bool auth = true});

  Future<Response> patch(String url, List<Json>? data);

  Future<Response> post(String url, Json? data, {bool auth = true});
}

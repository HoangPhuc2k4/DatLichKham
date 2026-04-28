import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class ApiException implements Exception {
  final int status;
  final String code;
  final String message;
  ApiException({required this.status, required this.code, required this.message});

  @override
  String toString() => 'ApiException($status, $code): $message';
}

class ApiClient {
  ApiClient._internal();
  static final ApiClient instance = ApiClient._internal();

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = AppConfig.apiBaseUrl;
    final normalized = path.startsWith('/') ? path : '/$path';
    final u = Uri.parse('$base$normalized');
    return query == null ? u : u.replace(queryParameters: query);
  }

  Future<dynamic> getJson(String path, {Map<String, String>? query}) async {
    final res = await http.get(_uri(path, query));
    return _decode(res);
  }

  Future<dynamic> postJson(String path, Map<String, dynamic> body) async {
    final res = await http.post(
      _uri(path),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _decode(res);
  }

  Future<dynamic> putJson(String path, Map<String, dynamic> body) async {
    final res = await http.put(
      _uri(path),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _decode(res);
  }

  Future<dynamic> deleteJson(String path) async {
    final res = await http.delete(_uri(path));
    return _decode(res);
  }

  dynamic _decode(http.Response res) {
    dynamic payload;
    try {
      payload = jsonDecode(res.body.isEmpty ? '{}' : res.body);
    } catch (_) {
      payload = {};
    }

    final ok = payload is Map && payload['ok'] == true;
    if (ok) return payload['data'];

    final err = payload is Map ? (payload['error'] as Map?) : null;
    final code = (err?['code'] as String?) ?? 'HTTP_${res.statusCode}';
    final message = (err?['message'] as String?) ?? 'Request failed';
    throw ApiException(status: res.statusCode, code: code, message: message);
  }
}


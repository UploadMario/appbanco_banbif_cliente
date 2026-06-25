import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class ApiClient {
  static const _storage = FlutterSecureStorage();
  static const Duration requestTimeout = Duration(seconds: 8);
  final http.Client _http;

  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  Future<void> saveToken(String token) => _storage.write(key: 'core_jwt', value: token);
  Future<void> clearToken() => _storage.delete(key: 'core_jwt');
  Future<String?> token() => _storage.read(key: 'core_jwt');

  Future<Map<String, dynamic>> get(String path) => _send('GET', path);
  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) => _send('POST', path, body: body);
  Future<Map<String, dynamic>> health() => get('/health');

  Future<Map<String, dynamic>> _send(String method, String path, {Map<String, dynamic>? body}) async {
    try {
      final jwt = await token();
      final response = await (method == 'GET'
              ? _http.get(_uri(path), headers: _headers(jwt))
              : _http.post(_uri(path), headers: _headers(jwt), body: jsonEncode(body ?? {})))
          .timeout(requestTimeout);
      final decoded = _decode(response);
      if (response.statusCode == 401) {
        throw ApiException(response.statusCode, decoded['detail']?.toString() ?? 'Credenciales incorrectas.');
      }
      if (response.statusCode == 403) {
        throw ApiException(response.statusCode, decoded['detail']?.toString() ?? 'Rol no autorizado.');
      }
      if (response.statusCode >= 500) {
        throw ApiException(response.statusCode, decoded['detail']?.toString() ?? 'Error interno del Core.');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(response.statusCode, decoded['detail']?.toString() ?? 'Error del Core.');
      }
      return decoded;
    } on TimeoutException {
      throw const ApiException(408, 'Tiempo agotado conectando al Core. Revisa IP/firewall.');
    } on SocketException {
      throw const ApiException(0, 'No hay conexion con el servidor. Verifica IP, red o adb reverse.');
    } on http.ClientException {
      throw const ApiException(0, 'No hay conexion con el servidor. Verifica IP, red o adb reverse.');
    } on FormatException {
      throw const ApiException(0, 'Respuesta invalida del Core.');
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.body.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw const FormatException('JSON root is not an object');
  }

  Uri _uri(String path) => Uri.parse('${ApiConfig.normalizedBaseUrl}${path.startsWith('/') ? path : '/$path'}');

  Map<String, String> _headers(String? jwt) => {
        'Content-Type': 'application/json',
        if (jwt != null) 'Authorization': 'Bearer $jwt',
      };
}

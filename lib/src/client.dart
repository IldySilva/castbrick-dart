import 'dart:convert';
import 'package:http/http.dart' as http;

class CastBrickApiError extends Error {
  final int status;
  final String body;

  CastBrickApiError(this.status, this.body);

  @override
  String toString() => 'CastBrickApiError($status): $body';
}

class CastBrickClient {
  final String apiKey;
  final String baseUrl;
  final http.Client _httpClient;

  CastBrickClient({
    required this.apiKey,
    this.baseUrl = 'https://api.castbrick.co/v1',
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Uri _buildUri(String path, [Map<String, dynamic>? params]) {
    var normalizedBase = baseUrl;
    if (normalizedBase.endsWith('/')) {
      normalizedBase = normalizedBase.substring(0, normalizedBase.length - 1);
    }
    final uri = Uri.parse('$normalizedBase$path');
    if (params == null || params.isEmpty) return uri;

    final filtered = Map<String, dynamic>.from(params)
      ..removeWhere((key, value) => value == null);

    return uri.replace(
      queryParameters: filtered.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  Future<T> get<T>(String path, {Map<String, dynamic>? params}) async {
    final uri = _buildUri(path, params);
    final response = await _httpClient.get(uri, headers: _headers);
    return _parseResponse<T>(response);
  }

  Future<T> post<T>(String path, {Object? body}) async {
    final uri = _buildUri(path);
    final response = await _httpClient.post(
      uri,
      headers: _headers,
      body: body != null ? json.encode(body) : null,
    );
    return _parseResponse<T>(response);
  }

  Future<T> put<T>(String path, {Object? body}) async {
    final uri = _buildUri(path);
    final response = await _httpClient.put(
      uri,
      headers: _headers,
      body: body != null ? json.encode(body) : null,
    );
    return _parseResponse<T>(response);
  }

  Future<void> delete(String path) async {
    final uri = _buildUri(path);
    final response = await _httpClient.delete(uri, headers: _headers);
    if (response.statusCode != 204 && response.statusCode >= 400) {
      _throwError(response);
    }
  }

  T _parseResponse<T>(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.statusCode == 204 || response.body.isEmpty) {
        return null as T;
      }
      final decoded = json.decode(response.body);
      return decoded as T;
    }
    _throwError(response);
  }

  Never _throwError(http.Response response) {
    final body = response.body.isNotEmpty
        ? response.body
        : response.reasonPhrase ?? '';
    throw CastBrickApiError(response.statusCode, body);
  }

  void close() {
    _httpClient.close();
  }
}

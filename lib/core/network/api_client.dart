import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quex/core/constants/app_constants.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConstants.apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    if (AppConstants.useDummyData) {
      throw ApiException('Dummy mode: use repository implementations');
    }

    final response = await _client.get(
      Uri.parse('$_baseUrl$path'),
      headers: _defaultHeaders(headers),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    if (AppConstants.useDummyData) {
      throw ApiException('Dummy mode: use repository implementations');
    }

    final response = await _client.post(
      Uri.parse('$_baseUrl$path'),
      headers: _defaultHeaders(headers),
      body: jsonEncode(body ?? {}),
    );
    return _handleResponse(response);
  }

  Map<String, String> _defaultHeaders(Map<String, String>? headers) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?headers,
    };
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw ApiException(
      'Request failed (${response.statusCode})',
      statusCode: response.statusCode,
    );
  }
}

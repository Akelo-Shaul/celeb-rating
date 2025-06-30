// api_service.dart
// Provides generic HTTP methods (GET, POST, DELETE) for all other service classes.
// Centralizes the logic for making requests to the backend server.

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.100.58:8080/api';

  static Future<List<T>> fetchList<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
    print('GET $baseUrl/$endpoint => \\${response.statusCode} \\${response.body}');
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => fromJson(e)).toList();
    } else {
      throw Exception('Failed to load data: \\${response.statusCode} \\${response.body}');
    }
  }

  static Future<T> fetchOne<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
    if (response.statusCode == 200) {
      return fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<T> post<T>(
    String endpoint,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    print('POST $baseUrl/$endpoint => ${response.statusCode} ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to post data: ${response.statusCode} ${response.body}');
    }
  }

  static Future<List<T>> postList<T>(
    String endpoint,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List data = json.decode(response.body);
      return data.map((e) => fromJson(e)).toList();
    } else {
      throw Exception('Failed to post data');
    }
  }

  static Future<void> delete(String endpoint) async {
    final response = await http.delete(Uri.parse('$baseUrl/$endpoint'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete');
    }
  }
}

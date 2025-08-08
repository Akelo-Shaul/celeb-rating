// api_service.dart
// Provides generic HTTP methods (GET, POST, DELETE) for all other service classes.
// Centralizes the logic for making requests to the backend server.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../app_state.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.100.64:8081/api';

  // Helper to refresh token
  static Future<String?> refreshToken(BuildContext context) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final refreshToken = appState.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) return null;
    final headers = <String, String>{'Authorization': 'Bearer $refreshToken'};
    final response = await http.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final newToken = data['accessToken'] as String?;
      final newRefresh = data['refreshToken'] as String?;
      if (newToken != null) appState.jwtToken = newToken;
      if (newRefresh != null) appState.refreshToken = newRefresh;
      return newToken;
    }
    return null;
  }

  static Future<List<T>> fetchList<T>(
      String endpoint,
      T Function(Map<String, dynamic>) fromJson, {
        String? token,
        BuildContext? context,
      }) async {
    try {
      return await _fetchList<T>(endpoint, fromJson, token: token);
    } catch (e) {
      if (e.toString().contains('401') && context != null) {
        final newToken = await refreshToken(context);
        if (newToken != null) {
          return await _fetchList<T>(endpoint, fromJson, token: newToken);
        }
      }
      rethrow;
    }
  }

  static Future<List<T>> _fetchList<T>(
      String endpoint,
      T Function(Map<String, dynamic>) fromJson, {
        String? token,
      }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => fromJson(e)).toList();
    } else {
      throw Exception(
        'Failed to load data: \\${response.statusCode} \\${response.body}',
      );
    }
  }

  static Future<T> fetchOne<T>(
      String endpoint,
      T Function(Map<String, dynamic>) fromJson, {
        String? token,
        BuildContext? context,
      }) async {
    try {
      return await _fetchOne<T>(endpoint, fromJson, token: token);
    } catch (e) {
      if (e.toString().contains('401') && context != null) {
        final newToken = await refreshToken(context);
        if (newToken != null) {
          return await _fetchOne<T>(endpoint, fromJson, token: newToken);
        }
      }
      rethrow;
    }
  }

  static Future<T> _fetchOne<T>(
      String endpoint,
      T Function(Map<String, dynamic>) fromJson, {
        String? token,
      }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<T> post<T>(
      String endpoint,
      Map<String, dynamic> body,
      T Function(Map<String, dynamic>) fromJson, {
        String? token,
        BuildContext? context,
      }) async {
    try {
      return await _post<T>(endpoint, body, fromJson, token: token);
    } catch (e) {
      if (e.toString().contains('401') && context != null) {
        final newToken = await refreshToken(context);
        if (newToken != null) {
          return await _post<T>(endpoint, body, fromJson, token: newToken);
        }
      }
      rethrow;
    }
  }

  static Future<T> _post<T>(
      String endpoint,
      Map<String, dynamic> body,
      T Function(Map<String, dynamic>) fromJson, {
        String? token,
      }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: json.encode(body),
    );
    print(
      'POST $baseUrl/$endpoint => \\${response.statusCode} \\${response.body}',
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to post data: \\${response.statusCode} \\${response.body}',
      );
    }
  }

  static Future<List<T>> postList<T>(
      String endpoint,
      Map<String, dynamic> body,
      T Function(Map<String, dynamic>) fromJson, {
        String? token,
        BuildContext? context,
      }) async {
    try {
      return await _postList<T>(endpoint, body, fromJson, token: token);
    } catch (e) {
      if (e.toString().contains('401') && context != null) {
        final newToken = await refreshToken(context);
        if (newToken != null) {
          return await _postList<T>(endpoint, body, fromJson, token: newToken);
        }
      }
      rethrow;
    }
  }

  static Future<List<T>> _postList<T>(
      String endpoint,
      Map<String, dynamic> body,
      T Function(Map<String, dynamic>) fromJson, {
        String? token,
      }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: json.encode(body),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List data = json.decode(response.body);
      return data.map((e) => fromJson(e)).toList();
    } else {
      throw Exception('Failed to post data');
    }
  }

  static Future<T> put<T>(
      String endpoint,
      Map<String, dynamic> body,
      T Function(Map<String, dynamic>) fromJson, {
        String? token,
        BuildContext? context,
      }) async {
    try {
      return await _put<T>(endpoint, body, fromJson, token: token);
    } catch (e) {
      if (e.toString().contains('401') && context != null) {
        final newToken = await refreshToken(context);
        if (newToken != null) {
          return await _put<T>(endpoint, body, fromJson, token: newToken);
        }
      }
      rethrow;
    }
  }

  static Future<T> _put<T>(
      String endpoint,
      Map<String, dynamic> body,
      T Function(Map<String, dynamic>) fromJson, {
        String? token,
      }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final response = await http.put(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: json.encode(body),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to put data: \\${response.statusCode} \\${response.body}',
      );
    }
  }

  static Future<void> delete(
      String endpoint, {
        String? token,
        BuildContext? context,
      }) async {
    try {
      await _delete(endpoint, token: token);
    } catch (e) {
      if (e.toString().contains('401') && context != null) {
        final newToken = await refreshToken(context);
        if (newToken != null) {
          await _delete(endpoint, token: newToken);
        }
      }
      rethrow;
    }
  }

  static Future<void> _delete(String endpoint, {String? token}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final response = await http.delete(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete');
    }
  }
}

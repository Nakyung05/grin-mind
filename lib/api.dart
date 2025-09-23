// lib/api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import './models.dart';

const String baseUrl = 'http://127.0.0.1:5000/api';

class Api {
  static Future<String> signup(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      return 'ok';
    } else {
      final error = jsonDecode(response.body)['error'];
      throw Exception(error);
    }
  }

  static Future<String> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'];
      } else {
        final error = jsonDecode(response.body)['error'];
        throw Exception(error);
      }
    } catch (e) {
      throw Exception('로그인 실패: $e');
    }
  }

  static Future<List<ActionItem>> getActions(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/actions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items.map((json) => ActionItem.fromJson(json)).toList();
    } else {
      final error = jsonDecode(response.body)['error'];
      throw Exception(error);
    }
  }

  static Future<void> updateActionCount(
      String token, int actionId, int delta) async {
    final response = await http.post(
      Uri.parse('$baseUrl/actions/$actionId/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'delta': delta}),
    );
    if (response.statusCode != 200) {
      final error = jsonDecode(response.body)['error'];
      throw Exception(error);
    }
  }

  static Future<LeaderboardData> getLeaderboard(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/leaderboard'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return LeaderboardData.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body)['error'];
      throw Exception(error);
    }
  }
}
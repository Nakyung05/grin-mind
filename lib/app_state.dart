import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'api.dart';
import 'models.dart';

class AppState extends ChangeNotifier {
  String? _email;
  List<LeaderboardItem> _lb = [];
  MeInfo _me = MeInfo(total: 0, weeklyTotal: 0);
  List<ActionItem> _actions = [];

  String? get email => _email;
  List<LeaderboardItem> get leaderboard => _lb;
  MeInfo get me => _me;
  List<ActionItem> get actions => _actions;

  bool isMonday() {
    return DateTime.now().weekday == DateTime.monday;
  }

  Future<void> login(String email, String password) async {
    final res = await Api.postJson('/api/login', {'email': email, 'password': password});
    await Api.saveToken(res['token']);
    _email = email;
    notifyListeners();
  }

  Future<void> signup(String email, String password) async {
    await Api.postJson('/api/signup', {'email': email, 'password': password});
  }

  Future<void> logout() async {
    await Api.clearToken();
    _email = null;
    _lb = [];
    _me = MeInfo(total: 0, weeklyTotal: 0);
    _actions = [];
    notifyListeners();
  }

  Future<void> fetchLeaderboard() async {
    final res = await Api.getJson('/api/leaderboard', auth: true);
    final items = (res['leaderboard'] as List? ?? []);
    _lb = items.map((e) => LeaderboardItem.fromMap(e)).toList();
    _me = MeInfo.fromMap(res['me'] as Map?);
    notifyListeners();
  }

  Future<void> fetchActions() async {
    final res = await Api.getJson('/api/actions', auth: true);
    final items = (res['items'] as List? ?? []);
    _actions = items.map((e) => ActionItem.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> addActionDelta(int actionId, int delta) async {
    await Api.postJson('/api/actions/$actionId/add', {'delta': delta}, auth: true);
    await fetchActions();
    await fetchLeaderboard();
  }
}
  
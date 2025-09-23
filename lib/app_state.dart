// lib/app_state.dart
import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  String? _token;

  String? get token => _token;
  bool get isAuthenticated => _token != null;

  void login(String token) {
    _token = token;
    notifyListeners();
  }

  void logout() {
    _token = null;
    notifyListeners();
  }
}
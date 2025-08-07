import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _authToken;
  String? _username;
  bool _isLoading = false;

  bool get isLoggedIn => _isLoggedIn;
  String? get authToken => _authToken;
  String? get username => _username;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void login(String token, String username) {
    _authToken = token;
    _username = username;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _authToken = null;
    _username = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}

// lib/app_state.dart

import 'package:cooperative_market/models/user/user_model.dart';
import 'package:flutter/material.dart';

// A provider class for managing the app's state, such as authentication.
class AppState extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _authToken;
  User? _currentUser;
  bool _isLoading = false;
  bool get isAuthenticated => _authToken != null;

  bool get isLoggedIn => _isLoggedIn;
  String? get authToken => _authToken;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void login(String token, User user) {
    _authToken = token;
    _currentUser = user;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _authToken = null;
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}

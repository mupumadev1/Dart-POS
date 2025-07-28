import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;                    // Use underscore, not asterisk
  bool _isLoading = false;        // Use underscore, not asterisk
  final ApiService _apiService = ApiService(); // Use underscore, not asterisk

  // Getters
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  bool get isAdmin => _user?.role == 'admin';

  Future<void> initialize() async {
    await _apiService.loadToken();
    // You might want to validate the token here
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _apiService.login(username, password);
      print(_user);
      return _user != null;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    _user = null;
    notifyListeners();
  }
}
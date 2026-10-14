import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    // Check if auto-login or initial session exists
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _apiService.login(username, password);
    _isLoading = false;

    if (result['success'] == true) {
      _isAuthenticated = true;
      _currentUser = UserModel.initial().copyWith(
        code: username,
      );
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Login gagal';
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> updatePassword(String newPassword) async {
    _isLoading = true;
    notifyListeners();

    final res = await _apiService.updatePassword(newPassword);
    _isLoading = false;
    notifyListeners();
    return res['success'] == true;
  }
}

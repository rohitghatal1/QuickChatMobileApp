import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class AuthController with ChangeNotifier {
  final AuthService authService;
  final ApiService apiService;

  AuthController({
    required this.authService,
    required this.apiService,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? _currentUser;
  User? get currentUser => _currentUser;

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await apiService.post(
        '/auth/register',
        {
          'username': username,
          'email': email,
          'password': password,
        },
      );

      await authService.saveAuthData(response['token'], response['_id']);
      _currentUser = User(
        id: response['_id'],
        username: response['username'],
        email: response['email'],
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await apiService.post(
        '/auth/login',
        {
          'email': email,
          'password': password,
        },
      );

      await authService.saveAuthData(response['token'], response['_id']);
      _currentUser = User(
        id: response['_id'],
        username: response['username'],
        email: response['email'],
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await authService.clearAuthData();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final token = authService.getToken();
    if (token != null) {
      // Here you would typically fetch user data
      final userId = authService.getUserId();
      if (userId != null) {
        _currentUser = User(id: userId, username: 'User', email: 'user@example.com');
      }
    }
  }
}
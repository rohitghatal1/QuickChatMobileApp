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

  /// Register User
  Future<void> register({
    required String name,
    required int number,
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
          'name': name,
          'number': number,
          'username': username,
          'email': email,
          'password': password,
        },
      );

      await authService.saveAuthData(response['token'], response['_id']);
      _currentUser = User(
        id: response['_id'],
        name: response['name'],
        username: response['username'],
        number: response['number'],
        email: response['email'],
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login User
  Future<void> login({
    required int number,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await apiService.post(
        '/auth/login',
        {
          'number': number,
          'password': password,
        },
      );

      await authService.saveAuthData(response['token'], response['_id']);

      // Since login response doesn't send user details, you may need to fetch it
      // If user data is returned from login, use this:
      _currentUser = User(
        id: response['_id'],
        name: response['name'] ?? '',
        username: response['username'] ?? '',
        number: response['number'] ?? '',
        email: response['email'] ?? '',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout User
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try{
      await authService.clearAuthData();
      _currentUser = null;
    } finally{
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check Auth Status
  Future<void> checkAuthStatus() async {
    final token = authService.getToken();
    if (token != null) {
      // Here you would typically fetch user data
      final userId = authService.getUserId();
      if (userId != null) {
        // You may want to fetch user details if needed
        _currentUser = User(id: userId, name: 'User', email: 'rohitghatal@gmail.com', username: 'username', number: '9806415229');
      }
    }
  }
}

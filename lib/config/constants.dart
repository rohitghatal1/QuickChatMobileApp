class AppConstants {
  static const String appName = 'QuickChat';
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  // static const String baseUrl = 'http://localhost:5000/api';
  static const String socketUrl = 'http://10.0.2.2:5000'; // For Android emulator
// static const String socketUrl = 'http://localhost:5000'; // For iOS simulator
}

class ApiEndpoints {
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String users = '/chat/users';
  static const String messages = '/chat/messages';
}
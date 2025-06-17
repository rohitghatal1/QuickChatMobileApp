import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/auth_controller.dart';
import '../utils/Dio/myDio.dart';
import 'auth/login_screen.dart';
import 'chat/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuthStatus());
  }

  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("quickChatAccessToken");

      if (token != null && token.isNotEmpty) {
        print('Debug: Token found and set in Dio');
      } else {
        print('Debug: No token found in prefs');
      }

      final authController = Provider.of<AuthController>(context, listen: false);
      await authController.checkAuthStatus(); // Assumes this fetches current user using MyDio

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => authController.currentUser != null
              ? const HomeScreen()
              : const LoginScreen(),
        ),
      );
    } catch (e) {
      print('Error in _checkAuthStatus: $e');
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_chat/services/firebaseService.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/auth_controller.dart';
import '../provider/UserProvider.dart';
import '../utils/Dio/myDio.dart';
import 'auth/login_screen.dart';
import 'chat/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  List<dynamic>  currentUser = [];
  @override
  void initState() {
    super.initState();
    initializeApp();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuthStatus());
  }

  void initializeApp() async{
    var provider = Provider.of<UserProvider>(context, listen: false);
    await provider.getConfig();
    await FirebaseService.requestNotificationPermission();
    var id = provider.userData["_id"];
    debugPrint("provider data f $id");
    FirebaseService.subscribeToTopic(id);
    debugPrint("initialized user provider");
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

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => token != null
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

  // Future<void> getLoggedInUser() async {
  //   try {
  //     final dio = await MyDio().getDio();
  //     final response = await dio.get("/users/auth/me");
  //     setState(() {
  //       currentUser = response.data;
  //     });
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Failed to fetch current user data')),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

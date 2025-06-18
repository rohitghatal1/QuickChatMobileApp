import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'controllers/auth_controller.dart';
import 'controllers/chat_controller.dart';
import 'services/auth_service.dart';
import 'services/socket_service.dart';
import 'services/api_service.dart';
import 'views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final sharedPreferences = await SharedPreferences.getInstance();
  final apiService = ApiService();
  final authService = AuthService(sharedPreferences: sharedPreferences);
  final socketService = SocketService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController(authService: authService, apiService: apiService)),
        ChangeNotifierProvider(create: (_) => ChatController(apiService: apiService, socketService: socketService, authService: authService)),
      ],
      child: MyApp(authService: authService),
    ),
  );
}

final GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  final AuthService authService;

  const MyApp({Key? key, required this.authService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.teal,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white
          )
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black87),
          titleLarge: TextStyle(color: Colors.teal.shade900),
          labelLarge: TextStyle(color: Colors.teal)
        )
      ),

      home: SplashScreen(),
    );
  }
}

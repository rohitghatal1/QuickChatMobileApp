import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quick_chat/provider/UserProvider.dart';
import 'package:quick_chat/services/firebaseService.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'controllers/auth_controller.dart';
import 'controllers/chat_controller.dart';
import 'services/auth_service.dart';
import 'services/socket_service.dart';
import 'services/api_service.dart';
import 'views/splash_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final sharedPreferences = await SharedPreferences.getInstance();
  final apiService = ApiService();
  final authService = AuthService(sharedPreferences: sharedPreferences);
  final socketService = SocketService();
  await Hive.initFlutter();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController(authService: authService, apiService: apiService)),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MyApp(authService: authService),
    ),
  );
}

final GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  final AuthService authService;

  const MyApp({Key? key, required this.authService}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseService.initializeLocalNotifications();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseService.setupFirebaseMessaging(context);
    });
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Fredoka",
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

import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  //initialize local notificaitons
  static void initializeLocalNotifications() {
    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings("@mipmap/ic_launcher");
    const DarwinInitializationSettings iosInitializationSettings =
    DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    _localNotificationsPlugin.initialize(
        settings,
        //foreground notification for ontap logic
        onDidReceiveNotificationResponse: (NotificationResponse response){
          final payload = response.payload;
          if(payload != null){
            final data = Map<String, dynamic>.from(jsonDecode(payload));
            // navigationKey.currentState?.push(
            //   MaterialPageRoute(
            //     builder: (_) => Announcementdetailscreen(notificationData: data),
            //   ),
            // );
          }
        }
    );
  }

  //request notification permission
  static Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true, sound: true, badge: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User granted permission");
    } else {
      print("User denied permission");
    }
  }

  //listen for notification even the app is in the foreground
  static void setupFirebaseMessaging(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground notification: ${message.notification?.title}");
      showNotification(message);
    });

    //background notification on tap logic
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // navigationKey.currentState?.push(
      //   MaterialPageRoute(
      //     builder: (_) =>
      //         Announcementdetailscreen(notificationData: message.data),
      //   ),
      // );
      debugPrint("sending notification data ${message.data}");
    });
  }

  //display local notification
  static void showNotification(RemoteMessage message) async {
    //generating a unique id to prevent from replacing the earlier notification
    int notificationId =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000) % 2147483647;

    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails("high_importance_channel", "bharosa",
        importance: Importance.max, priority: Priority.high);
    NotificationDetails platformDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: DarwinNotificationDetails());

    await _localNotificationsPlugin.show(
        notificationId,
        message.notification?.title,
        message.notification?.body,
        platformDetails,
        payload: jsonEncode(message.data)
    );
  }

  static Future<void> subscribeToTopic(String topic) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? userType = prefs.getString("userType");
    // String topic;
    // // Unsubscribe from all topics first
    // await _firebaseMessaging.unsubscribeFromTopic("PAINTER");
    // await _firebaseMessaging.unsubscribeFromTopic("DEALER");
    // await _firebaseMessaging.unsubscribeFromTopic("ALLUSER");

    await _firebaseMessaging.subscribeToTopic(topic);
    String? token = await FirebaseMessaging.instance.getToken(
        vapidKey: "BBwpJhU1CkzjJuyW2b7AJ5gaDgRYIdxy57jrpoaziCvpmiuEfNl52-WL-us8W7qtLTh4OP8lvxtAklzi0GC-dSk"
    );
    debugPrint("got token5435 $token");

    // if(userType == "Painter"){
    //   topic = "PAINTER";
    // }
    // else if(userType == "Dealer"){
    //   topic = "DEALER";
    // }
    // else{
    //   topic = "ALLUSER";
    // }
    // await _firebaseMessaging.subscribeToTopic(topic);
    print("subscribed to topic");
  }
}

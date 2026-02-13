import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:construction_client/main.dart'; // Import for navigatorKey

// Top-level function for background handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling a background message: ${message.messageId}');
  // Note: Actual navigation logic for background tap is handled by onMessageOpenedApp
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    // 1. Request Permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
      return;
    }

    // 2. Get FCM Token
    _fcmToken = await _firebaseMessaging.getToken();
    debugPrint("FCM Token: $_fcmToken");

    // 3. Initialize Local Notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            '@mipmap/ic_launcher'); // Verify icon name

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            onDidReceiveLocalNotification: (id, title, body, payload) async {
      // Handle iOS foreground notification tap for older versions if needed
    });

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Handle foreground notification tap
        if (details.payload != null) {
          _handleMessageInteraction(jsonDecode(details.payload!));
        }
      },
    );

    // 4. Set Background Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 5. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint(
            'Message also contained a notification: ${message.notification}');

        // Show Local Notification
        _showLocalNotification(message);
      }
    });

    // 6. Handle Background/Terminated Notification Tap logic
    _setupInteractedMessage();
  }

  Future<void> _setupInteractedMessage() async {
    // 6.a. Terminated State (App opened from terminated state via notification)
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessageInteraction(initialMessage.data);
    }

    // 6.b. Background State (App opened from background via notification)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessageInteraction(message.data);
    });
  }

  void _handleMessageInteraction(Map<String, dynamic> data) {
    debugPrint("Handling interaction with data: $data");

    // Parse category and targetId
    String? category = data['category'];
    String? targetId = data['target_id'] ??
        data['targetId']; // Handle both snake_case and camelCase just in case

    debugPrint("Notification: category=$category, targetId=$targetId");

    if (category == null) return;

    // Use navigatorKey to navigate
    final validContext = navigatorKey.currentContext;
    if (validContext == null) {
      // Should wait/retry if context is not ready,
      // but typically calling this after main builds is fine.
      // For initialMessage, we might need a delay or route storage.
      // However, often navigatorKey.currentState is available once MaterialApp is built.
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleMessageInteraction(data);
      });
      return;
    }

    // Logic for redirection based on Category
    // Example categories: 'NEWS', 'REPAIR_UPDATE', 'PAYMENT', etc.
    // Adjust route names based on your app's routes
    switch (category) {
      case 'NEWS':
      case 'ANNOUNCEMENT':
        navigatorKey.currentState
            ?.pushNamed('/api/notifications'); // Or specific detail page
        break;
      case 'REPAIR':
        navigatorKey.currentState?.pushNamed('/repair');
        break;
      case 'PAYMENT':
        navigatorKey.currentState?.pushNamed('/payment');
        break;
      case 'PROGRESS':
        navigatorKey.currentState?.pushNamed('/progress');
        break;
      default:
        // Default to notification list if category unknown
        // navigatorKey.currentState?.pushNamed('/notifications');
        // Assuming current route structure check main.dart
        // There is no /notifications route in main.dart yet.
        // Maybe we need to add it or navigate to home first.
        break;
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel', // id
            'High Importance Notifications', // title
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: jsonEncode(message.data), // Pass data as payload
      );
    }
  }
}

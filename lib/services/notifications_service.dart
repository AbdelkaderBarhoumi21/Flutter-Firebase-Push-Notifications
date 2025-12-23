import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_firebase_push_notifications/firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  //handler => handles messages when the app is in the background or terminated
  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    //firebase must be initialized in background isolate
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    //init local notifications plugin and show notifications
    await _initializeLocalNotification();
    await _showFlutterNotification(message);
  }

  /// Initializes Firebase Messaging and Local Notifications
  static Future<void> initializeNotification() async {
    // Request permissions (required on iOS, optional on Android)
    await _firebaseMessaging.requestPermission();

    // Called when message is received while app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _showFlutterNotification(message);
    });

    // Called when app is brought to foreground from background by tapping a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("App opened from background notification: \${message.data}");
      // Don't invoke 'print' in production code
    });

    // Get and print FCM token (for sending targeted messages)
    await _getFcmToken();

    // Initialize the local notification plugin
    await _initializeLocalNotification();

    // Check if app was launched by tapping on a notification
    await _getInitialNotification();
  }

  /// Fetches and prints FCM token (optionally)
  static Future<void> _getFcmToken() async {
    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token"); // Don't invoke 'print' in production code
    // Use this token to send messages to this device
  }

  /// Initializes the local notification system (both Android and iOS)
  static Future<void> _initializeLocalNotification() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iOSInit = DarwinInitializationSettings();

    final InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iOSInit,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("User tapped notification: \${response.payload}");
        // Don't invoke 'print' in production code
      },
    );
  }

  /// Shows a local notification when a message is received
  static Future<void> _showFlutterNotification(RemoteMessage message) async {
    Map<String, dynamic>? data = message.data;

    String title = message.notification?.title ?? data['title'] ?? 'No Title';
    String body = message.notification?.body ?? data['body'] ?? 'No Body';

    // Android notification config
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'CHANNEL_ID', // Must be unique
      'CHANNEL_NAME',
      channelDescription: 'Notification channel for basic tests',
      priority: Priority.high,
      importance: Importance.high,
    );

    // iOS notification config
    DarwinNotificationDetails iOSDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Combine platform-specific settings
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    // Show notification
    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      notificationDetails,
    );
  }

  static Future<void> _getInitialNotification() async {
    RemoteMessage? message = await FirebaseMessaging.instance
        .getInitialMessage();

    if (message != null) {
      debugPrint(
        'App launced from terminated state via notifications ${message.data}',
      );
    }
  }
}

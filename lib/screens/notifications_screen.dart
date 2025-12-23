import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_push_notifications/screens/notifications_details_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  //Push Notifications

  void firebaseMessaging() async {
    //firebase messaging init

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    //FCM token
    String? token = await messaging.getToken();

    debugPrint(
      '==========================FCM Token: $token==========================',
    );
    //Foreground notificATIONS
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? 'N/A';
      final body = message.notification?.body ?? 'N/A';
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(
            body,
            maxLines: 1,
            style: TextStyle(overflow: TextOverflow.ellipsis),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      NotificationsDetailsScreen(body: body, title: title),
                ),
              ),
              child: Text('Next'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        ),
      );
    });

    //Background notifications => app not closed
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final title = message.notification?.title ?? 'N/A';
      final body = message.notification?.body ?? 'N/A';
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NotificationsDetailsScreen(body: body, title: title),
        ),
      );
    });

    //App in termination state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        final title = message.notification?.title ?? 'N/A';
        final body = message.notification?.body ?? 'N/A';
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                NotificationsDetailsScreen(body: body, title: title),
          ),
        );
      }
    });
  }

  @override
  void initState() {
    firebaseMessaging();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Push notifications',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
    );
  }
}

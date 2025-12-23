import 'package:flutter/material.dart';

class NotificationsDetailsScreen extends StatelessWidget {
  const NotificationsDetailsScreen({
    required this.body,
    required this.title,
    super.key,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notifications Details")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(body),
          ],
        ),
      ),
    );
  }
}

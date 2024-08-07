import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class TokenScreen extends StatefulWidget {
  const TokenScreen({super.key});

  @override
  _TokenScreenState createState() => _TokenScreenState();
}

class _TokenScreenState extends State<TokenScreen> {
  String? _deviceToken;

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _getDeviceToken();
  }

  // Method to request notification permissions
  void _requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false, // Only applicable for iOS
      badge: true,
      carPlay: false,
      criticalAlert: false, // Only applicable for iOS
      provisional: false, // Provisional notifications
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User granted permission");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("User granted provisional permission");
    } else {
      print("User denied permission");
    }
  }

  // Method to get the device token and print it in the console
  Future<void> _getDeviceToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      setState(() {
        _deviceToken = token;
      });
      if (token != null) {
        print("Device Token: $token");
      } else {
        print("Failed to get device token.");
      }
    } catch (e) {
      print("Error getting device token: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FCM Device Token'),
      ),
      body: Center(
        child: _deviceToken == null
            ? const CircularProgressIndicator()
            : const Text('Device Token fetched. Check console for details.'),
      ),
    );
  }
}

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class TokenScreen extends StatefulWidget {
  @override
  _TokenScreenState createState() => _TokenScreenState();
}

class _TokenScreenState extends State<TokenScreen> {
  String? _deviceToken;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _getDeviceToken();
  }

  Future<void> _getDeviceToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      setState(() {
        _deviceToken = token;
        _isLoading = false;
      });
      if (token != null) {
        print("Device Token: $token");
      } else {
        setState(() {
          _error = "Failed to get device token.";
        });
        print("Failed to get device token.");
      }
    } catch (e) {
      setState(() {
        _error = "Error getting device token: $e";
        _isLoading = false;
      });
      print("Error getting device token: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FCM Device Token'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : _deviceToken != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Device Token: $_deviceToken'),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _getDeviceToken,
                        child: Text('Refresh Token'),
                      ),
                    ],
                  )
                : _error != null
                    ? Text(_error!)
                    : Text('No token available.'),
      ),
    );
  }
}

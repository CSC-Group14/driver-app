import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class TokenManager {
  final String driverId;

  TokenManager({required this.driverId});

  Future<void> storeToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        DatabaseReference driverRef =
            FirebaseDatabase.instance.ref().child('Drivers').child(driverId);
        await driverRef.update({'deviceToken': token});
        print("Device token stored for driver $driverId: $token");
      } else {
        print("Failed to get device token.");
      }
    } catch (e) {
      print("Error storing device token: $e");
    }
  }
}

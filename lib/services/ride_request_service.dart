import 'package:firebase_database/firebase_database.dart';
import 'package:logitrust_drivers/models/riderequest.dart';

class RideRequestService {
  final DatabaseReference _rideRequestsRef =
      FirebaseDatabase.instance.ref().child('rideRequests');

  Future<void> declineRideRequest(String rideRequestId) async {
    try {
      await _rideRequestsRef.child(rideRequestId).update({
        'status': 'Pending',
        'driverId': null,
      });
    } catch (error) {
      print('Error declining ride request: $error');
    }
  }

  Future<void> acceptRideRequest(String rideRequestId, String driverId) async {
    try {
      await _rideRequestsRef.child(rideRequestId).update({
        'status': 'Accepted',
        'driverId': driverId,
      });
    } catch (error) {
      print('Error accepting ride request: $error');
    }
  }

  Stream<Map<String, RideRequest>> getRideRequestsStream() {
    return _rideRequestsRef.onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) {
        return {};
      }
      return data.map((key, value) {
        final rideRequest = RideRequest.fromMap(value as Map<String, dynamic>);
        return MapEntry(key, rideRequest);
      });
    });
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logitrust_drivers/mainScreens/new_trip_screen.dart';
import 'package:logitrust_drivers/models/riderequest.dart';
import 'package:logitrust_drivers/widgets/push_notification_dialog.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final DatabaseReference _rideRequestsRef =
      FirebaseDatabase.instance.ref().child('AllRideRequests');
  late Stream<DatabaseEvent> _rideRequestsStream;

  @override
  void initState() {
    super.initState();
    _rideRequestsStream = _rideRequestsRef.onValue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ride Requests')),
      body: StreamBuilder<DatabaseEvent>(
        stream: _rideRequestsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData ||
              snapshot.data!.snapshot.value == null) {
            return const Center(child: Text('No ride requests available.'));
          } else {
            final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            final rideRequests = data.entries
                .map((entry) {
                  final request = entry.value;
                  if (request is Map<dynamic, dynamic>) {
                    final rideRequest = RideRequest.fromMap(request);
                    return rideRequest;
                  }
                  return null;
                })
                .whereType<RideRequest>()
                .toList();

            rideRequests.sort((a, b) => b.timestamp.compareTo(a.timestamp));

            return ListView.builder(
              itemCount: rideRequests.length,
              itemBuilder: (context, index) {
                final request = rideRequests[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(request.userName),
                    subtitle: Text(
                      'From: ${request.sourceAddress}\n'
                      'To: ${request.destinationAddress}\n'
                      'Time: ${request.time}\n'
                      'Status: ${request.status}',
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () => _acceptRide(request),
                    ),
                    onLongPress: () => _showRideRequestDialog(request.id),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _acceptRide(RideRequest request) async {
    try {
      await _rideRequestsRef.child(request.id).update({
        'status': 'Accepted',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewTripScreen(
            rideRequest: request,
          ),
        ),
      );
    } catch (e) {
      print('Error updating ride status: $e');
    }
  }

  void _showRideRequestDialog(String rideRequestId) {
    showRideRequestDialog(context, rideRequestId);
  }
}

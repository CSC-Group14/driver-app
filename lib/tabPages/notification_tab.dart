import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logitrust_drivers/mainScreens/new_trip_screen.dart';
import 'package:logitrust_drivers/models/riderequest.dart';

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
            // Parse ride requests
            final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;


            // Ensure data is in the expected format and filter out empty requests
            final rideRequests = data.entries
                .map((entry) {
                  final request = entry.value;

                  // Check if the request is a Map
                  if (request is Map<dynamic, dynamic>) {
                    // Create a RideRequest instance and validate required fields
                    final rideRequest = RideRequest(
                      id: entry.key.toString(),
                      destinationAddress: request['destinationAddress'] ?? '',
                      sourceAddress: request['sourceAddress'] ?? '',
                      time: request['time'] ?? '',
                      userName: request['userName'] ?? '',
                      userPhone: request['userPhone'] ?? '',
                      status: request['status'] ?? '',
                    );

                    // Return the rideRequest if it has all required fields
                    if (rideRequest.destinationAddress.isNotEmpty &&
                        rideRequest.sourceAddress.isNotEmpty &&
                        rideRequest.time.isNotEmpty &&
                        rideRequest.userName.isNotEmpty &&
                        rideRequest.userPhone.isNotEmpty) {
                      return rideRequest;
                    }
                  }

                  // Handle unexpected data format or empty request
                  print('Invalid or empty ride request: $entry');
                  return null; // or return a default value
                })
                .whereType<RideRequest>()
                .toList();
          


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
      // Optionally show an error message to the user
    }
  }
}

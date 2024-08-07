import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:logitrust_drivers/mainScreens/new_trip_screen.dart';
import 'package:logitrust_drivers/models/riderequest.dart';

// Import the NewTripScreen

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
    // Set up the stream to listen to ride requests
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
            final rideRequests = data.entries.map((entry) {
              final request = entry.value as Map<dynamic, dynamic>;
              return RideRequest(
                id: entry.key.toString(),
                destinationAddress: request['destinationAddress'] ?? '',
                sourceAddress: request['sourceAddress'] ?? '',
                time: request['time'] ?? '',
                userName: request['userName'] ?? '',
                userPhone: request['userPhone'] ?? '',
                status: request['status'] ?? '',
                
              );
            }).toList();

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
                        'From: ${request.sourceAddress}\nTo: ${request.destinationAddress}\nTime: ${request.time}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => _acceptRide(request),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            // Handle reject action
                            print('Rejected: ${request.id}');
                          },
                        ),
                      ],
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

  // Method to handle the acceptance of a ride
  void _acceptRide(RideRequest request) async {
    try {
      // Update the ride request status in the database
      await _rideRequestsRef.child(request.id).update({
        'status': 'Accepted',
      });

      // Navigate to the TripScreen with the ride request details
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewTripScreen(
            rideRequest: request, // Use the request passed as a parameter
          ),
        ),
      );
    } catch (e) {
      print('Error updating ride status: $e');
      // Optionally show an error message to the user
    }
  }
}

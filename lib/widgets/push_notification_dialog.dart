import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logitrust_drivers/mainScreens/new_trip_screen.dart';
import 'package:logitrust_drivers/models/riderequest.dart';

class RideRequestDialog extends StatefulWidget {
  final String rideRequestId;

  RideRequestDialog({required this.rideRequestId});

  @override
  _RideRequestDialogState createState() => _RideRequestDialogState();
}

class _RideRequestDialogState extends State<RideRequestDialog> {
  late DatabaseReference _rideRequestRef;
  RideRequest? _rideRequest;

  @override
  void initState() {
    super.initState();
    _rideRequestRef = FirebaseDatabase.instance
        .ref()
        .child("AllRideRequests")
        .child(widget.rideRequestId);

    _fetchRideRequestData();
  }

  Future<void> _fetchRideRequestData() async {
    try {
      final event = await _rideRequestRef.once();
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final rideRequest = RideRequest.fromMap(data);

        setState(() {
          _rideRequest = rideRequest;
        });
      } else {
        setState(() {
          _rideRequest = null; // or show an appropriate message
        });
      }
    } catch (error) {
      print("Error fetching ride request data: $error");
    }
  }

  void _acceptRide() async {
    if (_rideRequest != null) {
      try {
        await _rideRequestRef.update({
          'status': 'Accepted',
        });

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => NewTripScreen(
              rideRequest: _rideRequest!,
            ),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ride request accepted.')),
        );
      } catch (e) {
        print('Error updating ride status: $e');
      }
    }
  }

  Future<void> _declineRideRequest() async {
    try {
      await _rideRequestRef.update({
        'status': 'Declined',
      });

      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ride request declined.')),
      );
    } catch (error) {
      print("Error declining ride request: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("New Ride Request"),
      content: _rideRequest == null
          ? CircularProgressIndicator()
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pickup Details
                  Row(
                    children: [
                      Image.asset(
                        'images/source.png',
                        width: 25,
                        height: 25,
                      ),
                      const SizedBox(width: 22),
                      Expanded(
                        child: Container(
                          child: Text(
                            "Source Address: ${_rideRequest!.sourceAddress}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  // Destination Details
                  Row(
                    children: [
                      Image.asset(
                        'images/destination.png',
                        width: 25,
                        height: 25,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Container(
                          child: Text(
                            "Destination Address: ${_rideRequest!.destinationAddress}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
          onPressed: _acceptRide,
          child: const Text(
            "Accept",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: _declineRideRequest,
          child: const Text(
            "Decline",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            "Cancel",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

bool _dialogShowing = false;

void showRideRequestDialog(BuildContext context, String rideRequestId) async {
  if (_dialogShowing) return;

  final rideRequestRef = FirebaseDatabase.instance
      .ref()
      .child('AllRideRequests')
      .child(rideRequestId);
  final snapshot = await rideRequestRef.once();

  if (snapshot.snapshot.value != null) {
    _dialogShowing = true;
    showDialog(
      context: context,
      builder: (context) {
        return RideRequestDialog(rideRequestId: rideRequestId);
      },
    ).then((_) {
      _dialogShowing = false; // Reset the flag when the dialog is closed
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ride request not found.')),
    );
  }
}

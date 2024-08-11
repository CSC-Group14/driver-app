import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logitrust_drivers/models/riderequest.dart';
import 'package:logitrust_drivers/mainScreens/new_trip_screen.dart';

class RideRequestDialog extends StatefulWidget {
  final String rideRequestId;

  RideRequestDialog({required this.rideRequestId});

  @override
  _RideRequestDialogState createState() => _RideRequestDialogState();
}

class _RideRequestDialogState extends State<RideRequestDialog> {
  final DatabaseReference _rideRequestRef =
      FirebaseDatabase.instance.ref().child('AllRideRequests');
      late Stream<DatabaseEvent> _rideRequestsStream;
  late RideRequest request;

  @override
  void initState() {
    super.initState();
    _fetchRideRequestData();
    _rideRequestsStream = _rideRequestRef.onValue;
  }

  void _fetchRideRequestData() {
    _rideRequestRef.child(widget.rideRequestId).once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final rideRequest = RideRequest.fromMap(data);

        setState(() {
          request = rideRequest;
        });
      } else {
        Navigator.of(context).pop(); // Close the dialog if no data
      }
    }).catchError((error) {
      print("Error fetching ride request data: $error");
      Navigator.of(context).pop(); // Close the dialog if there's an error
    });
  }

  void _acceptRide() async {
    if (request != null) {
      try {
        await _rideRequestRef.child(request!.id).update({
          'status': 'Accepted',
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NewTripScreen(
              rideRequest: request!,
            ),
          ),
        );
      } catch (e) {
        print('Error updating ride status: $e');
      }
    }
  }

  void _declineRideRequest() {
    if (request != null) {
      _rideRequestRef.child(request!.id).update({'status': 'Declined'}).then((_) {
        Navigator.of(context).pop(); // Close the dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ride request declined.')),
        );
      }).catchError((error) {
        print("Error declining ride request: $error");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return AlertDialog(
      title: Text("New Ride Request"),
      content: request == null
          ? Text("No ride request data available.") // Optional
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
                            "Source Address: ${request!.sourceAddress}",
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
                            "Destination Address: ${request!.destinationAddress}",
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

  final rideRequestRef = FirebaseDatabase.instance.ref().child('AllRideRequests').child(rideRequestId);
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

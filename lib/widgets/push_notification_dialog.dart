import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
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

  void _fetchRideRequestData() {
    _rideRequestRef.once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final rideRequest = RideRequest.fromMap(data);

        if (rideRequest.status == 'Pending') {
          setState(() {
            _rideRequest = rideRequest;
          });
        } else {
          // Close the dialog if the status is not pending
          Navigator.of(context).pop();
        }
      } else {
        // Handle case when data does not exist
        setState(() {
          _rideRequest = null; // or show an appropriate message
        });
      }
    }).catchError((error) {
      print("Error fetching ride request data: $error");
    });
  }

  void _acceptRideRequest() {
    _rideRequestRef.once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final rideRequest = RideRequest.fromMap(data);

        if (rideRequest.status == 'Pending') {
          // Update the status to accepted
          _rideRequestRef.update({
            'status': 'Accepted',
            'acceptedBy': 'DriverID', // Replace 'DriverID' with the actual driver ID
          }).then((_) {
            Navigator.of(context).pop(); // Close the dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ride request accepted.')),
            );
          }).catchError((error) {
            print("Error accepting ride request: $error");
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('This ride request has already been handled.')),
          );
          Navigator.of(context).pop(); // Close the dialog
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ride request not found.')),
        );
        Navigator.of(context).pop(); // Close the dialog
      }
    }).catchError((error) {
      print("Error fetching ride request data: $error");
    });
  }

  void _declineRideRequest() {
    _rideRequestRef.update({'status': 'Declined'}).then((_) {
      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ride request declined.')),
      );
    }).catchError((error) {
      print("Error declining ride request: $error");
    });
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
          onPressed: _acceptRideRequest,
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

void showRideRequestDialog(BuildContext context, String rideRequestId) {
  showDialog(
    context: context,
    builder: (context) {
      return RideRequestDialog(rideRequestId: rideRequestId);
    },
  );
}

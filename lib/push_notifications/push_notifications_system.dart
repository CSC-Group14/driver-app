// import 'package:assets_audio_player/assets_audio_player.dart';
// import 'package:logitrust_drivers/models/ride_request_information.dart';
// import 'package:logitrust_drivers/widgets/push_notification_dialog.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// import '../global/global.dart';

// class PushNotificationSystem {
  

//   Future retrieveRideRequestInformation(
//       String rideRequestID, BuildContext context) async {
//     try {
//       DatabaseEvent event = await FirebaseDatabase.instance
//           .ref()
//           .child("AllRideRequests")
//           .child(rideRequestID)
//           .once();

//       DataSnapshot snapshot =
//           event.snapshot; // Access the DataSnapshot from the DatabaseEvent

//       if (snapshot.exists) {
//         audioPlayer.open(Audio("music/music_notification.mp3"));
//         audioPlayer.play();

//         String? rideRequestID = snapshot.key;

//         double sourceLat = (snapshot.value as Map)["source"]["latitude"];
//         double sourceLng = (snapshot.value as Map)["source"]["longitude"];
//         String sourceAddress = (snapshot.value as Map)["sourceAddress"];

//         double destinationLat =
//             (snapshot.value as Map)["destination"]["latitude"];
//         double destinationLng =
//             (snapshot.value as Map)["destination"]["longitude"];
//         String destinationAddress =
//             (snapshot.value as Map)["destinationAddress"];

//         String userName = (snapshot.value as Map)["userName"];
//         String userPhone = (snapshot.value as Map)["userPhone"];

//         RideRequestInformation rideRequestInformation =
//             RideRequestInformation();
//         rideRequestInformation.rideRequestId = rideRequestID;
//         rideRequestInformation.userName = userName;
//         rideRequestInformation.userPhone = userPhone;
//         rideRequestInformation.sourceLatLng = LatLng(sourceLat, sourceLng);
//         rideRequestInformation.destinationLatLng =
//             LatLng(destinationLat, destinationLng);
//         rideRequestInformation.sourceAddress = sourceAddress;
//         rideRequestInformation.destinationAddress = destinationAddress;

//         showDialog(
//           context: context,
//           builder: (BuildContext context) => NotificationDialogBox(
//             rideRequestInformation: rideRequestInformation,
//           ),
//         );
//       } else {
//         Fluttertoast.showToast(msg: "This ride request is invalid!");
//       }
//     } catch (error) {
//       Fluttertoast.showToast(msg: "Error retrieving ride request: $error");
//     }
//   }
// }

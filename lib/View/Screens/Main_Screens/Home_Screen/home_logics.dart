import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logitrust_drivers/Container/Repositories/address_parser_repo.dart';
import 'package:logitrust_drivers/Container/Repositories/firestore_repo.dart';
import 'package:logitrust_drivers/Container/utils/error_notification.dart';
import 'package:logitrust_drivers/View/Screens/Main_Screens/Home_Screen/home_providers.dart';
import 'package:logitrust_drivers/services/firestore_services.dart';

class HomeLogics {
  /// [getDriverLoc] fetches the driver's location as soon as user start the app
  void getDriverLoc(BuildContext context, WidgetRef ref,
      GoogleMapController controller) async {
    try {
      /// get driver's location
      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      /// animate camera to current driver's location
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(pos.latitude, pos.longitude), zoom: 14)));

      /// If mounted, get human readable address of the driver
      if (context.mounted) {
        await ref.watch(globalAddressParserProvider).humanReadableAddress(
              pos,
              context,
              ref,
            );
      }
    } catch (e) {
      /// Handle errors
      if (context.mounted) {
        ErrorNotification().showError(context, "An Error Occurred $e");
      }
    }
  }

  /// [getDriverOnline] sets driver's online status and tracks location
  void getDriverOnline(BuildContext context, WidgetRef ref,
      GoogleMapController controller) async {
    try {
      /// Create location's Geo Point using Firestore's GeoPoint
      GeoPoint myLocation = GeoPoint(
          ref.read(homeScreenDriversLocationProvider)!.locationLatitude!,
          ref.read(homeScreenDriversLocationProvider)!.locationLongitude!);

      /// Set driver's current location
      ref.read(globalFirestoreRepoProvider).setDriverLocationStatus(
            context,
            myLocation,
          );

      /// Track driver's location as driver moves
      Geolocator.getPositionStream().listen((event) {
        GeoPoint newLocation = GeoPoint(event.latitude, event.longitude);
        ref.read(globalFirestoreRepoProvider).setDriverLocationStatus(
              context,
              newLocation,
            );
      });

      /// Driver's current position in [LatLng]
      LatLng driverPos = LatLng(
          ref.read(homeScreenDriversLocationProvider)!.locationLatitude!,
          ref.read(homeScreenDriversLocationProvider)!.locationLongitude!);

      /// Animate to current driver's position
      controller.animateCamera(CameraUpdate.newLatLng(driverPos));

      /// Set driver's status and update state
      ref.read(globalFirestoreRepoProvider).setDriverStatus(context, "Idle");
      ref
          .watch(homeScreenIsDriverActiveProvider.notifier)
          .update((state) => true);
    } catch (e) {
      /// Handle errors
      ErrorNotification().showError(context, "An Error Occurred $e");
    }
  }

  /// [getDriverOffline] sets driver's offline status and cleans up
  void getDriverOffline(BuildContext context, WidgetRef ref) async {
    try {
      /// Deactivate Driver
      ref
          .watch(homeScreenIsDriverActiveProvider.notifier)
          .update((state) => false);

      /// Set Driver's status to be offline
      ref.read(globalFirestoreRepoProvider).setDriverStatus(context, "offline");

      /// Remove driver's location from database
      ref
          .read(globalFirestoreRepoProvider)
          .setDriverLocationStatus(context, null);

      /// Delay for better user experience
      await Future.delayed(const Duration(seconds: 2));

      /// Close the application
      SystemChannels.platform.invokeMethod("SystemNavigator.pop");

      /// Show success message
      if (context.mounted) {
        ErrorNotification().showSuccess(context, "You are now Offline");
      }
    } catch (e) {
      /// Handle errors
      if (context.mounted) {
        ErrorNotification().showError(context, "An Error Occurred $e");
      }
    }
  }

  void listenForRideRequests(BuildContext context, WidgetRef ref) {
    FirebaseFirestore.instance
        .collection('rideRequests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var rideRequest = snapshot.docs.first;

        String userName = rideRequest['userName'];
        String userLocation = rideRequest['userLocation'];
        String destination = rideRequest['destination'];
        String rideRequestId = rideRequest.id; // Retrieve document ID

        // Logging for debugging
        print(
            'Detected new ride request: $userName, $userLocation, $destination');

        // Delayed showing of ride request dialog after 30 seconds
        Future.delayed(Duration(seconds: 30), () {
          print('Delay elapsed, showing dialog...');
          showRideRequestDialog(
              context, userName, userLocation, destination, rideRequestId);
        });
      }
    });
  }

  void showRideRequestDialog(BuildContext context, String userName,
      String userLocation, String destination, String rideRequestId) {
    print('Showing ride request dialog...');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('New Ride Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('User Name: $userName'),
              Text('User Location: $userLocation'),
              Text('Destination: $destination'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Decline'),
              onPressed: () {
                // Handle decline action
                declineRideRequest(rideRequestId);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Accept'),
              onPressed: () {
                // Handle accept action
                acceptRideRequest(rideRequestId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void acceptRideRequest(String rideRequestId) {
    FirebaseFirestore.instance
        .collection('rideRequests')
        .doc(rideRequestId)
        .update({
      'status': 'accepted',
    });
  }

  void declineRideRequest(String rideRequestId) {
    FirebaseFirestore.instance
        .collection('rideRequests')
        .doc(rideRequestId)
        .update({
      'status': 'declined',
    });
  }
}

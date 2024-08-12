import 'dart:async';

import 'package:logitrust_drivers/assistants/assistant_methods.dart';
import 'package:logitrust_drivers/global/global.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logitrust_drivers/widgets/push_notification_dialog.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  _HomeTabPageState createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  GoogleMapController? newMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  var geoLocator = Geolocator();
  LocationPermission? _locationPermission;

  // Set to track processed ride request IDs
  Set<String> processedRideRequestIds = {};

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  // Get Current Location of the driver
  locateDriverPosition() async {
    driverCurrentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    LatLng latLngPosition = LatLng(
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 16);
    newMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress =
        await AssistantMethods.searchAddressForGeographicCoordinates(
            driverCurrentPosition!, context);
    print("this is your address = $humanReadableAddress");
  }

  // Enable Push Notifications
  readCurrentDriverInformation() async {
    currentFirebaseUser = firebaseAuth.currentUser;

    await FirebaseDatabase.instance
        .ref()
        .child("Drivers")
        .child(currentFirebaseUser!.uid)
        .once()
        .then((snapData) {
      DataSnapshot snapshot = snapData.snapshot;
      if (snapshot.exists) {
        driverData.id = (snapshot.value as Map)["id"];
        driverData.name = (snapshot.value as Map)["name"];
        driverData.email = (snapshot.value as Map)["email"];
        driverData.phone = (snapshot.value as Map)["phone"];
        driverData.carColor = (snapshot.value as Map)["carDetails"]["carColor"];
        driverData.carModel = (snapshot.value as Map)["carDetails"]["carModel"];
        driverData.carNumber =
            (snapshot.value as Map)["carDetails"]["carNumber"];
        driverData.carType = (snapshot.value as Map)["carDetails"]["carType"];
        driverData.lastTripId = (snapshot.value as Map)["lastTripId"];
        driverData.totalEarnings = (snapshot.value as Map)["totalEarnings"];
      }
    });

    AssistantMethods.getLastTripInformation(context);
    AssistantMethods.getDriverRating(context);
  }

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed();
    readCurrentDriverInformation();
    AssistantMethods.readRideRequestKeys(context);
    _rideRequestsRef = FirebaseDatabase.instance.ref().child("AllRideRequests");

    _rideRequestsRef.onChildAdded.listen((DatabaseEvent event) async {
      final rideRequestId = event.snapshot.key;
      if (rideRequestId != null &&
          !processedRideRequestIds.contains(rideRequestId)) {
        // Fetch ride request details
        DatabaseReference rideRequestRef = FirebaseDatabase.instance
            .ref()
            .child("AllRideRequests")
            .child(rideRequestId);

        // Using event.snapshot to access the data
        final snapshot = await rideRequestRef.once();
        final rideRequestData = snapshot.snapshot.value as Map?;

        // Check for null source and destination IDs
        final sourceId = rideRequestData?['source'];
        final destinationId = rideRequestData?['destination'];
        final rideRequestStatus = rideRequestData?['status'] ?? '';

        if (sourceId != null &&
            destinationId != null &&
            rideRequestStatus != 'Accepted') {
          _showRideRequestDialog(rideRequestId);
          processedRideRequestIds.add(rideRequestId); // Add to processed IDs
        }
      }
    });
  }

  late DatabaseReference _rideRequestsRef;

  void _showRideRequestDialog(String rideRequestId) {
    showDialog(
      context: context,
      builder: (context) {
        return RideRequestDialog(
          rideRequestId: rideRequestId,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          myLocationEnabled: true,
          zoomControlsEnabled: true,
          zoomGesturesEnabled: true,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controllerGoogleMap.complete(controller);
            newMapController = controller;
            locateDriverPosition();
          },
        ),
        statusText != "Online"
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                color: Colors.black54,
              )
            : Container(),
        Positioned(
          top: statusText != "Online"
              ? MediaQuery.of(context).size.height * 0.46
              : 35,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {
                    if (statusText != "Online") {
                      // Offline
                      driverIsOnlineNow();
                      updateDriversLocationAtRealTime();

                      setState(() {
                        statusText = "Online";
                        isDriverActive = true;
                        buttonColor = Colors.black;
                      });

                      Fluttertoast.showToast(msg: "You are online now");
                    } else {
                      driverIsOfflineNow();
                      setState(() {
                        statusText = "Offline";
                        isDriverActive = false;
                        buttonColor = Colors.black;
                      });

                      Fluttertoast.showToast(msg: "You are offline now");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26))),
                  child: statusText != "Online"
                      ? Text(
                          statusText,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )
                      : const Icon(
                          Icons.phonelink_ring,
                          color: Colors.white,
                          size: 30,
                        ))
            ],
          ),
        )
      ],
    );
  }

  driverIsOnlineNow() async {
    driverCurrentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    Geofire.initialize("ActiveDrivers");
    Geofire.setLocation(currentFirebaseUser!.uid,
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

    DatabaseReference reference = FirebaseDatabase.instance
        .ref()
        .child("Drivers")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus");

    reference.set("Idle");
    reference.onValue.listen((event) {});
  }

  driverIsOfflineNow() async {
    Geofire.removeLocation(currentFirebaseUser!.uid);

    DatabaseReference? reference = FirebaseDatabase.instance
        .ref()
        .child("Drivers")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus");

    reference.onDisconnect();
    reference.remove(); // child newRideStatus removed
    reference = null;
  }

  updateDriversLocationAtRealTime() {
    streamSubscriptionPosition =
        Geolocator.getPositionStream().listen((Position position) {
      driverCurrentPosition = position;

      if (isDriverActive == true) {
        Geofire.setLocation(currentFirebaseUser!.uid,
            driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
      }

      LatLng latLng = LatLng(
        driverCurrentPosition!.latitude,
        driverCurrentPosition!.longitude,
      );

      newMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }
}

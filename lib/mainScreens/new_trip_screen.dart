// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'package:logitrust_drivers/global/global.dart';
import 'package:logitrust_drivers/models/riderequest.dart';
import 'package:logitrust_drivers/widgets/fare_amount_collection_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../assistants/assistant_methods.dart';
import '../widgets/progress_dialog.dart';

const CameraPosition googlePlexInitialPosition = CameraPosition(
  target: LatLng(0.3476, 32.5825), // Kampala, Uganda
  zoom: 14.4746,
);

class NewTripScreen extends StatefulWidget {
  final RideRequest? rideRequest;

  const NewTripScreen({super.key, this.rideRequest});

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  GoogleMapController? newTripMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Set<Marker> setOfMarkers = <Marker>{};
  Set<Circle> setOfCircles = <Circle>{};
  Set<Polyline> polyLineSet = <Polyline>{};
  List<LatLng> polyLineCoordinatesList = [];
  PolylinePoints polylinePoints = PolylinePoints();
  double mapPadding = 0;
  var geoLocator = Geolocator();
  BitmapDescriptor? driverIconMarker;
  Position? driverLiveLocation;
  String rideRequestStatus = "Accepted";
  String buttonTitle = "Arrived";
  Color buttonColor = Colors.green;
  String durationFromSourceToDestination = "";
  bool isRequestDirectionDetails = false;

  Future<void> drawPolylineFromSourceToDestination(
      LatLng source, LatLng destination) async {
    if (source == null || destination == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(message: 'Please wait..'),
    );

    var directionDetailsInfo =
        await AssistantMethods.getOriginToDestinationDirectionDetails(
            source, destination);
    Navigator.pop(context);

    if (directionDetailsInfo == null) return;

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsList =
        polylinePoints.decodePolyline(directionDetailsInfo.e_points!);
    polyLineCoordinatesList.clear();

    if (decodedPolyLinePointsList.isNotEmpty) {
      for (var pointLatLng in decodedPolyLinePointsList) {
        polyLineCoordinatesList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }

    polyLineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.black,
        polylineId: const PolylineId("PolyLineID"),
        jointType: JointType.bevel,
        points: polyLineCoordinatesList,
        startCap: Cap.roundCap,
        endCap: Cap.squareCap,
        geodesic: true,
      );

      polyLineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if (source.latitude > destination.latitude &&
        source.longitude > destination.longitude) {
      boundsLatLng = LatLngBounds(southwest: destination, northeast: source);
    } else if (source.longitude > destination.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(source.latitude, destination.longitude),
        northeast: LatLng(destination.latitude, source.longitude),
      );
    } else if (source.latitude > destination.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destination.latitude, source.longitude),
        northeast: LatLng(source.latitude, destination.longitude),
      );
    } else {
      boundsLatLng = LatLngBounds(southwest: source, northeast: destination);
    }

    if (newTripMapController != null) {
      newTripMapController!
          .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));
    }

    Marker originMarker = Marker(
        markerId: const MarkerId("sourceID"),
        position: source,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: "Source"));

    Marker destinationMarker = Marker(
        markerId: const MarkerId("destinationID"),
        position: destination,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: "Destination"));

    setState(() {
      setOfMarkers.add(originMarker);
      setOfMarkers.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: Colors.black,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: source,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationID"),
      fillColor: Colors.black,
      radius: 12,
      strokeWidth: 15,
      strokeColor: Colors.white,
      center: destination,
    );

    setState(() {
      setOfCircles.add(originCircle);
      setOfCircles.add(destinationCircle);
    });
  }

  Future<void> endTrip() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProgressDialog(message: "Please wait");
      },
    );

    if (driverLiveLocation == null || widget.rideRequest == null) return;

    var currentDriverPositionLatLng =
        LatLng(driverLiveLocation!.latitude, driverLiveLocation!.longitude);

    var tripDirectionDetailsInfo =
        await AssistantMethods.getOriginToDestinationDirectionDetails(
            currentDriverPositionLatLng, widget.rideRequest!.source!);

    if (tripDirectionDetailsInfo == null) return;

    Fluttertoast.showToast(
        msg: "KM:${tripDirectionDetailsInfo.duration_text!} Time:${tripDirectionDetailsInfo.distance_text!}");

    double? fareAmount =
        AssistantMethods.calculateFareAmountFromSourceToDestination(
            tripDirectionDetailsInfo, driverData.carType);

    FirebaseDatabase.instance
        .ref()
        .child("AllRideRequests")
        .child(widget.rideRequest!.id)
        .child("status")
        .set("Ended");

    FirebaseDatabase.instance
        .ref()
        .child("AllRideRequests")
        .child(widget.rideRequest!.id)
        .child("fareAmount")
        .set(fareAmount);

    if (streamSubscriptionPosition != null) {
      streamSubscriptionPosition!.cancel();
    }

    Navigator.pop(context);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return FareAmountDialog(
              fareAmount: fareAmount, userName: widget.rideRequest!.userName);
        });

    FirebaseDatabase.instance
        .ref()
        .child("Drivers")
        .child(currentFirebaseUser!.uid)
        .child("totalEarnings")
        .once()
        .then((snapData) {
      DataSnapshot snapshot = snapData.snapshot;
      if (snapshot.exists) {
        double previousEarnings = double.parse(snapshot.value.toString());
        double totalEarning = previousEarnings + fareAmount;
        FirebaseDatabase.instance
            .ref()
            .child("Drivers")
            .child(currentFirebaseUser!.uid)
            .child("totalEarnings")
            .set(totalEarning.toString());
      } else {
        FirebaseDatabase.instance
            .ref()
            .child("Drivers")
            .child(currentFirebaseUser!.uid)
            .child("totalEarnings")
            .set(fareAmount.toString());
      }
    });
  }

  Future<String?> getPhoneNumberFromFirebase() async {
    DatabaseReference reference = FirebaseDatabase.instance
    .ref()
    .child('Users')
    .child(currentFirebaseUser!.uid)
    .child("phone");
    
    DataSnapshot snapshot = (await reference.once()) as DataSnapshot;
    
    if (snapshot.exists) {
      return snapshot.value.toString();
    }
    return null;
  }


  @override
  void initState() {
    super.initState();
    saveAssignedDriverDetailsToRideRequest();
  }

  @override
  Widget build(BuildContext context) {
    createActiveDriverIconMarker();
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            markers: setOfMarkers,
            circles: setOfCircles,
            polylines: polyLineSet,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newTripMapController = controller;

              setState(() {
                mapPadding = 320;
              });

              if (driverCurrentPosition != null && widget.rideRequest != null) {
                var driverCurrentLatLng = LatLng(
                    driverCurrentPosition!.latitude,
                    driverCurrentPosition!.longitude);

                // Debug log to check what source contains
                print("Source: ${widget.rideRequest!.source}");

                var source = widget.rideRequest!.source;

                if (source != null) {
                  // Check if source is a LatLng object or Map
                  LatLng sourceLatLng;
                  if (source is LatLng) {
                    sourceLatLng = source;
                  } else if (source is Map<String, dynamic>) {
                    // Convert Map to LatLng
                    sourceLatLng = sourceLatLng =
                        LatLng(source.latitude, source.longitude);
                  } else {
                    // Invalid format
                    Fluttertoast.showToast(
                        msg: "Invalid source location format.");
                    return;
                  }

                  drawPolylineFromSourceToDestination(
                      driverCurrentLatLng, sourceLatLng);
                } else {
                  Fluttertoast.showToast(msg: "Source location not available.");
                }

                updateDriversLocationAtRealTime();
              }
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 10,
                    spreadRadius: 0.5,
                    offset: Offset(0.6, 0.6),
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Column(
                  children: [
                    Text(
                      durationFromSourceToDestination,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    const Divider(
                      thickness: 2,
                      height: 2,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Text(
                          widget.rideRequest?.userName ?? 'User',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.phone_android,
                            color: Colors.black,
                          ),
                        ),
                        // IconButton(
                        //   icon: Icon(Icons.call, color: Colors.green),
                        //   onPressed: () {
                        //     // Check if the phone number is available
                        //     if (widget.rideRequest?.userPhone != null) {
                        //       _makePhoneCall(widget.rideRequest!.userPhone);
                        //     } else {
                        //       Fluttertoast.showToast(msg: "Phone number not available.");
                        //     }
                        //   },
                        // ),
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          "images/source.png",
                          width: 30,
                          height: 30,
                        ),
                        const SizedBox(
                          width: 14,
                        ),
                        Expanded(
                          child: Container(
                            child: Text(
                              widget.rideRequest?.sourceAddress ?? 'Address',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Image.asset(
                          "images/destination.png",
                          width: 30,
                          height: 30,
                        ),
                        const SizedBox(
                          width: 14,
                        ),
                        Expanded(
                          child: Container(
                            child: Text(
                              widget.rideRequest?.destinationAddress ??
                                  'Address',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (widget.rideRequest?.userPhone != null) {
                              _makePhoneCall(widget.rideRequest!.userPhone!);
                            } else {
                              Fluttertoast.showToast(msg: "Phone number not available.");
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 249, 247, 245), // Set button color
                            padding: const EdgeInsets.all(5.0),
                            textStyle: const TextStyle(color: Colors.white),
                          ),
                          child: const Text('Call'),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    const Divider(
                      thickness: 2,
                      height: 2,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (widget.rideRequest == null) return;

                        if (rideRequestStatus == "Accepted") {
                          rideRequestStatus = "Arrived";
                          setState(() {
                            buttonTitle = "Start Trip";
                            buttonColor = Colors.green;
                          });

                          FirebaseDatabase.instance
                              .ref()
                              .child("AllRideRequests")
                              .child(widget.rideRequest!.id)
                              .child("status")
                              .set(rideRequestStatus);

                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return ProgressDialog(message: "Loading");
                              });

                          await drawPolylineFromSourceToDestination(
                              widget.rideRequest!.source!,
                              widget.rideRequest!.destination!);

                          Navigator.pop(context);
                        } else if (rideRequestStatus == "Arrived") {
                          rideRequestStatus = "On Trip";
                          setState(() {
                            buttonTitle = "End Trip";
                            buttonColor = Colors.redAccent;
                          });

                          FirebaseDatabase.instance
                              .ref()
                              .child("AllRideRequests")
                              .child(widget.rideRequest!.id)
                              .child("status")
                              .set(rideRequestStatus);
                        } else if (rideRequestStatus == "On Trip") {
                          endTrip();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                      ),
                      icon: const Icon(
                        Icons.directions_car,
                        color: Colors.white,
                        size: 25,
                      ),
                      label: Text(
                        buttonTitle,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  saveAssignedDriverDetailsToRideRequest() {
    if (widget.rideRequest == null) return;

    DatabaseReference reference = FirebaseDatabase.instance
        .ref()
        .child("AllRideRequests")
        .child(widget.rideRequest!.id);

    Map driverCarDetailsMap = {
      "carColor": driverData.carColor,
      "carModel": driverData.carModel,
      "carNumber": driverData.carNumber,
      "carType": driverData.carType
    };

    Map driverLocationDataMap = {
      "latitude": driverCurrentPosition?.latitude,
      "longitude": driverCurrentPosition?.longitude,
    };

    reference.child("status").set("Accepted");
    reference.child("driverId").set(driverData.id);
    reference.child("driverName").set(driverData.name);
    reference.child("driverPhone").set(driverData.phone);
    reference.child("carDetails").set(driverCarDetailsMap);
    reference.child("driverLocationData").set(driverLocationDataMap);

    saveRideRequestId();
  }

  saveRideRequestId() {
    DatabaseReference reference = FirebaseDatabase.instance
        .ref()
        .child("Drivers")
        .child(currentFirebaseUser!.uid)
        .child("tripHistory");

    reference.child(widget.rideRequest!.id).set(true);
  }

  createActiveDriverIconMarker() {
    if (driverIconMarker == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/truck-2.png")
          .then((value) {
        driverIconMarker = value;
      });
    }
  }

  updateDriversLocationAtRealTime() {
    Fluttertoast.showToast(msg: "Inside updateDriversLocationAtRealTime()");
    streamSubscriptionPosition =
        Geolocator.getPositionStream().listen((Position position) {
      driverCurrentPosition = position;
      driverLiveLocation = position;

      if (driverLiveLocation == null) return;

      LatLng driverLivePositionLatLng = LatLng(
        driverLiveLocation!.latitude,
        driverLiveLocation!.longitude,
      );

      if (driverIconMarker != null) {
        Marker animatingCarMarker = Marker(
            markerId: const MarkerId("animatingCarMarker"),
            position: driverLivePositionLatLng,
            icon: driverIconMarker!,
            infoWindow: const InfoWindow(title: "Your Location"));

        setState(() {
          CameraPosition cameraPosition =
              CameraPosition(target: driverLivePositionLatLng, zoom: 16);
          newTripMapController
              ?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
          setOfMarkers.removeWhere(
              (element) => element.markerId.value == "animatingCarMarker");
          setOfMarkers.add(animatingCarMarker);
        });

        updateDurationAtRealTime();

        Map driverUpdatedLocationMap = {
          "latitude": driverLiveLocation!.latitude.toString(),
          "longitude": driverLiveLocation!.longitude.toString(),
        };

        FirebaseDatabase.instance
            .ref()
            .child("AllRideRequests")
            .child(widget.rideRequest!.id)
            .child("driverLocationData")
            .set(driverUpdatedLocationMap);
      }
    });
  }

  updateDurationAtRealTime() async {
    Fluttertoast.showToast(msg: "Inside updateDurationAtRealTime()");
    if (!isRequestDirectionDetails) {
      isRequestDirectionDetails = true;

      if (driverLiveLocation == null) return;

      var sourceLatLng =
          LatLng(driverLiveLocation!.latitude, driverLiveLocation!.longitude);
      var destinationLatLng = rideRequestStatus == "Accepted"
          ? widget.rideRequest?.source
          : widget.rideRequest?.destination;

      if (destinationLatLng == null) return;

      var directionDetailsInfo =
          await AssistantMethods.getOriginToDestinationDirectionDetails(
              sourceLatLng, destinationLatLng);

      if (directionDetailsInfo != null) {
        setState(() {
          durationFromSourceToDestination = directionDetailsInfo.duration_text!;
        });

        isRequestDirectionDetails = false;
      }
    }
  }

}
void _makePhoneCall(String phoneNumber) async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );
  if (await canLaunchUrl(launchUri)) {
    await launchUrl(launchUri);
  } else {
    Fluttertoast.showToast(msg: "Could not place the call.");
  }
}


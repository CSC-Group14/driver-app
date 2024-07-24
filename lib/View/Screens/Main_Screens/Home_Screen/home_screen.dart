import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logitrust_drivers/Container/Repositories/firestore_repo.dart';
import 'package:logitrust_drivers/View/Screens/Main_Screens/Home_Screen/home_logics.dart';
import 'package:logitrust_drivers/View/Screens/Main_Screens/Home_Screen/home_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final String destination;
  final GeoPoint userLocation;

  const HomeScreen(
      {Key? key, required this.destination, required this.userLocation})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  CameraPosition initpos =
      const CameraPosition(target: LatLng(0.0, 0.0), zoom: 14);
  final Completer<GoogleMapController> completer = Completer();
  GoogleMapController? controller;
  Geolocator geoLocator = Geolocator();
  Set<Marker> markers = {}; // Set to hold markers on the map
  BitmapDescriptor? truckIcon;

  @override
  void initState() {
    super.initState();
    _setCustomMarkerIcon();
    updateMapWithUserDetails(widget.destination, widget.userLocation);
    HomeLogics().listenForRideRequests(context, ref);
  }

  void _setCustomMarkerIcon() async {
    truckIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(48, 48)), // Customize the size if needed
      'images/truck.png',
    );
    setState(() {}); // Refresh the UI to use the new icon
  }

  void updateMapWithUserDetails(String destination, GeoPoint userLocation) {
    // Example method to update GoogleMap with user details
    if (controller != null) {
      controller!.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(userLocation.latitude, userLocation.longitude),
        14,
      ));

      markers.clear();
      markers.add(
        Marker(
          markerId: MarkerId('userLocationMarker'),
          position: LatLng(userLocation.latitude, userLocation.longitude),
          icon: truckIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'User Location',
            snippet: 'Destination: $destination',
          ),
        ),
      );

      setState(
          () {}); // Update the state to re-render the map with the new marker
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Stack(
            children: [
              GoogleMap(
                mapType: MapType.normal,
                myLocationButtonEnabled: true,
                trafficEnabled: true,
                compassEnabled: true,
                buildingsEnabled: true,
                myLocationEnabled: true,
                zoomControlsEnabled: false,
                zoomGesturesEnabled: true,
                initialCameraPosition: initpos,
                markers: markers, // Set of markers to display on the map
                onMapCreated: (map) {
                  completer.complete(map);
                  controller = map;
                  HomeLogics().getDriverLoc(context, ref, controller!);
                  ref
                      .watch(globalFirestoreRepoProvider)
                      .getDriverDetails(context);
                },
              ),
              ref.watch(homeScreenIsDriverActiveProvider)
                  ? Container()
                  : Container(
                      height: size.height,
                      width: size.width,
                      color: Colors.black54,
                    ),
              Positioned(
                top: !ref.watch(homeScreenIsDriverActiveProvider)
                    ? size.height * 0.45
                    : 45,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        if (!ref.watch(homeScreenIsDriverActiveProvider)) {
                          HomeLogics()
                              .getDriverOnline(context, ref, controller!);
                        } else {
                          HomeLogics().getDriverOffline(context, ref);
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 45,
                        width: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.blue,
                        ),
                        child: !ref.watch(homeScreenIsDriverActiveProvider)
                            ? const Text("Tap to go online")
                            : const Icon(Icons.phonelink_ring_outlined,
                                color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

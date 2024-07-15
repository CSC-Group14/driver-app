// ignore_for_file: unused_field, unused_local_variable, unnecessary_new

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> 
{

  Position? currentPosition;
  var geoLocator = Geolocator();

  void locatePosition() async
  {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy:LocationAccuracy.high);
    currentPosition = position;

    LatLng latLatPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition = new CameraPosition(target: latLatPosition,zoom: 14);
    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }
  GoogleMapController? newGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap =Completer();

   static const CameraPosition _kGooglePlex =  CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );



  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          myLocationEnabled: true,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller)
          {
            _controllerGoogleMap.complete(controller);
            newGoogleMapController = controller;

            locatePosition();

          },
        )
      ],
    );
  }
}
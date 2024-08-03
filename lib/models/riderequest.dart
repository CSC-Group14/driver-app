import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideRequest {
  final String id;
  final String destinationAddress;
  final String sourceAddress;
  LatLng? source;
  LatLng? destination;
  final String time;
  final String userName;
  final String userPhone;

  RideRequest({
    required this.id,
    required this.destinationAddress,
    required this.sourceAddress,
    this.source,
    this.destination,
    required this.time,
    required this.userName,
    required this.userPhone,
  });
}
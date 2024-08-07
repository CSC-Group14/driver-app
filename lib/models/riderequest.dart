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
  final String status; // Add status field

  RideRequest({
    required this.id,
    required this.destinationAddress,
    required this.sourceAddress,
    this.source,
    this.destination,
    required this.time,
    required this.userName,
    required this.userPhone,
    required this.status,
  });

  // Factory constructor to create a RideRequest from a map
  factory RideRequest.fromMap(Map<dynamic, dynamic> map) {
    return RideRequest(
      id: map['id'] ?? '',
      destinationAddress: map['destinationAddress'] ?? '',
      sourceAddress: map['sourceAddress'] ?? '',
      source: map['source'] != null ? LatLng(map['source']['latitude'], map['source']['longitude']) : null,
      destination: map['destination'] != null ? LatLng(map['destination']['latitude'], map['destination']['longitude']) : null,
      time: map['time'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      status: map['status'] ?? 'pending', // Default to 'pending' if not provided
    );
  }

  // Convert RideRequest to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'destinationAddress': destinationAddress,
      'sourceAddress': sourceAddress,
      'source': source != null ? {'latitude': source!.latitude, 'longitude': source!.longitude} : null,
      'destination': destination != null ? {'latitude': destination!.latitude, 'longitude': destination!.longitude} : null,
      'time': time,
      'userName': userName,
      'userPhone': userPhone,
      'status': status,
    };
  }
}

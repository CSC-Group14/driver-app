import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logitrust_drivers/models/riderequest.dart';


class TripScreen extends StatefulWidget {
  final RideRequest rideRequest;

  TripScreen({required this.rideRequest});

  @override
  _TripScreenState createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  late GoogleMapController _mapController;
  late LatLng _currentLatLng;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }
  

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentLatLng = LatLng(position.latitude, position.longitude);
    });

    // Update camera to fit the markers
    _mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: LatLng(
            _currentLatLng.latitude > (widget.rideRequest.destination?.latitude ?? _currentLatLng.latitude)
                ? _currentLatLng.latitude
                : (widget.rideRequest.destination?.latitude ?? _currentLatLng.latitude),
            _currentLatLng.longitude > (widget.rideRequest.destination?.longitude ?? _currentLatLng.longitude)
                ? _currentLatLng.longitude
                : (widget.rideRequest.destination?.longitude ?? _currentLatLng.longitude),
          ),
          southwest: LatLng(
            _currentLatLng.latitude < (widget.rideRequest.destination?.latitude ?? _currentLatLng.latitude)
                ? _currentLatLng.latitude
                : (widget.rideRequest.destination?.latitude ?? _currentLatLng.latitude),
            _currentLatLng.longitude < (widget.rideRequest.destination?.longitude ?? _currentLatLng.longitude)
                ? _currentLatLng.longitude
                : (widget.rideRequest.destination?.longitude ?? _currentLatLng.longitude),
          ),
        ),
        50,
      ),
    );
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trip Details')),
      body: _currentLatLng == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _currentLatLng,
                zoom: 14.0,
              ),
              markers: _createMarkers(),
              polylines: _createPolylines(),
            ),
    );
  }

  Set<Marker> _createMarkers() {
    return {
      if (widget.rideRequest.source != null)
        Marker(
          markerId: MarkerId('source'),
          position: widget.rideRequest.source!,
          infoWindow: InfoWindow(
            title: 'User Source Location',
            snippet: widget.rideRequest.sourceAddress,
          ),
        ),
      if (widget.rideRequest.destination != null)
        Marker(
          markerId: MarkerId('destination'),
          position: widget.rideRequest.destination!,
          infoWindow: InfoWindow(
            title: 'User Destination Location',
            snippet: widget.rideRequest.destinationAddress,
          ),
        ),
      Marker(
        markerId: MarkerId('current'),
        position: _currentLatLng,
        infoWindow: InfoWindow(
          title: 'Driver\'s Current Location',
        ),
      ),
    };
  }
  

  Set<Polyline> _createPolylines() {
    return {
      if (widget.rideRequest.source != null && widget.rideRequest.destination != null)
        Polyline(
          polylineId: PolylineId('route'),
          visible: true,
          points: [
            _currentLatLng,
            widget.rideRequest.source!,
            widget.rideRequest.destination!,
          ],
          color: Colors.blue,
          width: 4,
        ),
    };
  }
}

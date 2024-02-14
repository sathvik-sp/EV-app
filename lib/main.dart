import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool serviceEnabled;
  LocationPermission permission;

  // Request location permission
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Location permission is not granted, handle appropriately
      return;
    }
  }

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    Geolocator.requestPermission();
  }

  final currentPosition = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.best,
    forceAndroidLocationManager: true,
  );
  if (currentPosition != null) {
    final initialPosition =
        LatLng(currentPosition.latitude, currentPosition.longitude);

    runApp(MyApp(initialPosition: initialPosition));
  }
}

class MyApp extends StatelessWidget {
  final LatLng initialPosition;

  const MyApp({Key? key, required this.initialPosition}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Google Maps Flutter'),
        ),
        body: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: initialPosition,
            zoom: 16.0, // Zoom in closer initially
          ),
          markers: {
            Marker(
              markerId: MarkerId('currentLocation'),
              position: initialPosition,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue),
            ),
          },
          myLocationEnabled: true, // Enable continuous location updates
          onMapCreated: (GoogleMapController controller) {
            // Add additional markers or functionality if needed
          },
        ),
      ),
    );
  }
}

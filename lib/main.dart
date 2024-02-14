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

  final initialPosition =
      LatLng(currentPosition.latitude, currentPosition.longitude);

  runApp(MyApp(initialPosition: initialPosition));
}

class MyApp extends StatefulWidget {
  final LatLng initialPosition;

  MyApp({Key? key, required this.initialPosition}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double userLatitude = 0.0;
  double userLogitude = 0.0;

  late GoogleMapController mapController;

  void getlocation(double latitude, double longitude) {
    setState(() {
      userLatitude = latitude;
      userLogitude = longitude;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Google Maps Flutter'),
        ),
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.initialPosition,
                zoom: 16.0, // Zoom in closer initially
              ),
              markers: {
                Marker(
                  markerId: MarkerId('currentLocation'),
                  position: widget.initialPosition,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue),
                ),
              },

              myLocationEnabled: false, // Enable continuous location updates
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
                // Add additional markers or functionality if needed
              },
            ),
            Positioned(
              bottom: 40.0,
              right: 50.0,
              child: FloatingActionButton(
                onPressed: () async {
                  final currentPosition = await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.best,
                    forceAndroidLocationManager: true,
                  );

                  // userLatitude = currentPosition.latitude;
                  getlocation(
                      currentPosition.latitude, currentPosition.longitude);
                  mapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(
                          currentPosition.latitude,
                          currentPosition.longitude,
                        ),
                        zoom: 16.0,
                      ),
                    ),
                  );
                },
                child: Icon(
                  Icons.my_location,
                ),
              ),
            ),
            Text(
              '$userLatitude  $userLogitude',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}

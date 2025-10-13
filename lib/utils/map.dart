import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MainMap extends StatefulWidget {
  const MainMap({super.key});

  @override
  State<MainMap> createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  CameraOptions? _cameraOptions;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    await Permission.locationWhenInUse.request();

    bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    geo.LocationPermission permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.deniedForever || permission == geo.LocationPermission.denied) {
      return;
    }

    geo.Position position = await geo.Geolocator.getCurrentPosition(
      desiredAccuracy: geo.LocationAccuracy.high,
    );

    setState(() {
      _cameraOptions = CameraOptions(
        center: Point(coordinates: Position(position.longitude, position.latitude)),
        zoom: 14.0,
        bearing: 0,
        pitch: 24,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _cameraOptions == null
            ? Center(child: CircularProgressIndicator())
            : MapWidget(cameraOptions: _cameraOptions!),
      );
  }
}

import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:practica/config.dart';


class MainMap extends StatefulWidget {
  final List<Position>? cordenadasRuta; 

  const MainMap({super.key, this.cordenadasRuta});

  @override
  State<MainMap> createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  CameraOptions? _cameraOptions;
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager; //Para un punto
  PolylineAnnotationManager? _polylineAnnotationManager;// Para la linea
  PointAnnotation? _userMarker;
  PolylineAnnotation? _rutaActual;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    await Permission.locationWhenInUse.request();

    bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint("GPS desactivado");
      return;
    }

    geo.LocationPermission permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.deniedForever ||
        permission == geo.LocationPermission.denied) {
      debugPrint("Permisos de ubicación denegados");
      return;
    }

    geo.Position position = await geo.Geolocator.getCurrentPosition(
      desiredAccuracy: geo.LocationAccuracy.high,
    );

    setState(() {
      _cameraOptions = CameraOptions(
        center: Point(
          coordinates: Position(position.longitude, position.latitude),
        ),
        zoom: 14.0,
        bearing: 0,
        pitch: 24,
      );
    });
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
  }

  // firma correcta del callback
  void _onMapLoaded(MapLoadedEventData data) async {
    debugPrint("✅ Mapa completamente cargado y listo");

    _pointAnnotationManager =
        await _mapboxMap!.annotations.createPointAnnotationManager();
    _polylineAnnotationManager =
        await _mapboxMap!.annotations.createPolylineAnnotationManager();

    setState(() {
      _mapReady = true;
    });

    // Mostrar ubicación inicial y escuchar posición (como antes)...
    final pos = await geo.Geolocator.getCurrentPosition(
      desiredAccuracy: geo.LocationAccuracy.high,
    );
    _mostrarPunto(pos);

    geo.Geolocator.getPositionStream(
      locationSettings: const geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen(_actualizarPunto);
  }

  /// 🔹 Dibuja una ruta multipunto
  Future<void> _mostrarRutaMultiPunto() async {
    if (!_mapReady || _polylineAnnotationManager == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ El mapa aún no está listo para dibujar la ruta.'),
        ),
      );
      return;
    }

    const String mapboxAccessToken = AppConfig.mapboxAccessToken;

    final List<Position> puntosDeLaRuta = widget.cordenadasRuta ?? [
      Position(-103.4542, 25.5428), // Plaza Mayor
      Position(-103.4285, 25.5186), // Cristo de las Noas
      Position(-103.3989, 25.5683), // Galerías Laguna
      Position(-103.3820, 25.5653), // Aeropuerto
    ];

    if (puntosDeLaRuta.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Se necesitan al menos 2 puntos para trazar una ruta.'),
        ),
      );
      return;
    }

    final String coordinatesString =
        puntosDeLaRuta.map((p) => '${p.lng},${p.lat}').join(';');

    final String url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/$coordinatesString?geometries=geojson&access_token=$mapboxAccessToken';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coordinates = data['routes'][0]['geometry']['coordinates'];

        final List<Position> points = [];
        for (var coord in coordinates) {
          points.add(Position(coord[0], coord[1]));
        }

        if (_rutaActual != null) {
          await _polylineAnnotationManager?.delete(_rutaActual!);
        }

        final polylineOptions = PolylineAnnotationOptions(
          geometry: LineString(coordinates: points),
          lineColor: Colors.deepPurple.value,
          lineWidth: 6.0,
          lineOpacity: 0.9,
        );

        _rutaActual = await _polylineAnnotationManager?.create(polylineOptions);

        // 🔹 Mover cámara al centro de la ruta
        if (points.isNotEmpty && _mapboxMap != null) {
          final avgLat = points.map((p) => p.lat).reduce((a, b) => a + b) / points.length;
          final avgLng = points.map((p) => p.lng).reduce((a, b) => a + b) / points.length;

          await _mapboxMap!.flyTo(
            CameraOptions(
              center: Point(coordinates: Position(avgLng, avgLat)),
              zoom: 11.5,
            ),
            MapAnimationOptions(duration: 2000),
          );
        }
      } else {
        debugPrint('Error en la API de Mapbox: ${response.body}');
      }
    } catch (e) {
      debugPrint('Ocurrió un error al obtener la ruta: $e');
    }
  }

  Future<void> _mostrarPunto(geo.Position pos) async {
    if (_pointAnnotationManager == null) return;

    final ByteData bytes = await rootBundle.load("assets/icons/Marker.ico");
    final Uint8List list = bytes.buffer.asUint8List();

    final pointAnnotationOptions = PointAnnotationOptions(
      geometry: Point(coordinates: Position(pos.longitude, pos.latitude)),
      image: list,
      iconSize: 0.3,
    );

    _userMarker = await _pointAnnotationManager!.create(pointAnnotationOptions);
  }

  Future<void> _actualizarPunto(geo.Position pos) async {
    if (_userMarker == null) {
      await _mostrarPunto(pos);
      return;
    }

    _userMarker!.geometry =
        Point(coordinates: Position(pos.longitude, pos.latitude));
    await _pointAnnotationManager!.update(_userMarker!);

    _mapboxMap?.flyTo(
      CameraOptions(center: Point(coordinates: Position(pos.longitude, pos.latitude))),
      MapAnimationOptions(duration: 1000),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarRutaMultiPunto,
        tooltip: 'Mostrar Ruta de Ejemplo',
        child: const Icon(Icons.route),
      ),
      body: _cameraOptions == null
          ? const Center(child: CircularProgressIndicator())
          : MapWidget(
              cameraOptions: _cameraOptions!,
              key: const ValueKey("mapbox-map"),
              onMapCreated: _onMapCreated,
              onMapLoadedListener: _onMapLoaded,
              styleUri: MapboxStyles.MAPBOX_STREETS,
            ),
    );
  }
}

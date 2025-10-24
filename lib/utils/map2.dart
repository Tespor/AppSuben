import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:practica/config.dart';

class MainMap2 extends StatefulWidget {
  const MainMap2({super.key});

  @override
  State<MainMap2> createState() => _MainMap2State();
}

class _MainMap2State extends State<MainMap2> {
  CameraOptions? _cameraOptions;
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;
  PolylineAnnotationManager? _polylineAnnotationManager;
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

  void _onMapLoaded(MapLoadedEventData data) async {
    debugPrint("✅ Mapa completamente cargado y listo");

    _pointAnnotationManager =
        await _mapboxMap!.annotations.createPointAnnotationManager();
    _polylineAnnotationManager =
        await _mapboxMap!.annotations.createPolylineAnnotationManager();

    setState(() {
      _mapReady = true;
    });

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

  /// 🚍 Dibuja una ruta usando la respuesta real de la API de Mapbox
  Future<void> _mostrarRutaDesdeAPI() async {
    if (!_mapReady || _polylineAnnotationManager == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ El mapa aún no está listo para dibujar la ruta.'),
        ),
      );
      return;
    }

    const String accessToken = AppConfig.mapboxAccessToken;

    final String url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/'
        '-103.457085%2C25.535664%3B'
        '-103.415266%2C25.535454%3B'
        '-103.415373%2C25.516417%3B'
        '-103.399957%2C25.50759%3B'
        '-103.375912%2C25.534909%3B'
        '-103.316734%2C25.534402%3B'
        '-103.320196%2C25.548847'
        '?alternatives=true&annotations=distance%2Cduration'
        '&geometries=geojson&language=es&overview=full&steps=true'
        '&access_token=$accessToken';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final coordinates =
            data['routes'][0]['geometry']['coordinates'] as List<dynamic>;
        final waypoints = data['waypoints'] as List<dynamic>;

        // 🔹 Convertir coordenadas a lista de posiciones
        final List<Position> points = coordinates
            .map((coord) => Position(coord[0], coord[1]))
            .toList();

        // 🔹 Eliminar ruta previa si existe
        if (_rutaActual != null) {
          await _polylineAnnotationManager?.delete(_rutaActual!);
        }

        // 🔹 Dibujar la nueva línea
        final polylineOptions = PolylineAnnotationOptions(
          geometry: LineString(coordinates: points),
          lineColor: Colors.blueAccent.value,
          lineWidth: 5.5,
          lineOpacity: 0.9,
        );

        _rutaActual = await _polylineAnnotationManager?.create(polylineOptions);

        // 🔹 Mostrar marcadores en los waypoints (inicio y fin, opcional)
        if (waypoints.isNotEmpty) {
          final ByteData bytes = await rootBundle.load("assets/icons/Marker.ico");
          final Uint8List list = bytes.buffer.asUint8List();

          for (var wp in waypoints) {
            final loc = wp['location'];
            final name = wp['name'];
            await _pointAnnotationManager?.create(PointAnnotationOptions(
              geometry: Point(coordinates: Position(loc[0], loc[1])),
              image: list,
              iconSize: 0.25,
              textField: name,
              textOffset: [0, 1.5],
              textColor: Colors.white.value,
              textHaloColor: Colors.black.value,
              textHaloWidth: 1.2,
            ));
          }
        }

        // 🔹 Centrar cámara en el promedio de la ruta
        if (points.isNotEmpty && _mapboxMap != null) {
          final avgLat = points.map((p) => p.lat).reduce((a, b) => a + b) / points.length;
          final avgLng = points.map((p) => p.lng).reduce((a, b) => a + b) / points.length;

          await _mapboxMap!.flyTo(
            CameraOptions(
              center: Point(coordinates: Position(avgLng, avgLat)),
              zoom: 11.2,
            ),
            MapAnimationOptions(duration: 2000),
          );
        }
      } else {
        debugPrint("Error en la API: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Error al obtener ruta: $e");
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
        onPressed: _mostrarRutaDesdeAPI,
        tooltip: 'Mostrar Ruta desde API',
        child: const Icon(Icons.alt_route_rounded),
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

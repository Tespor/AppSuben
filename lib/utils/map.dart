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
  const MainMap({super.key});

  @override
  State<MainMap> createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  CameraOptions? _cameraOptions;
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;
  PointAnnotation? _userMarker;
  //Para trazar ruta
  PolylineAnnotationManager? _polylineAnnotationManager;
  PolylineAnnotation? _rutaActual;


  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  /// 🔹 Obtiene ubicación y configura cámara inicial
  Future<void> _initializeLocation() async {
    await Permission.locationWhenInUse.request();

    bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint("GPS desactivado");
      return;
    }

    geo.LocationPermission permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.deniedForever || permission == geo.LocationPermission.denied) {
      debugPrint("Permisos de ubicación denegados");
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

  /// 🔹 Se ejecuta cuando el mapa está listo
  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    _pointAnnotationManager = await _mapboxMap!.annotations.createPointAnnotationManager();

    _polylineAnnotationManager = await _mapboxMap!.annotations.createPolylineAnnotationManager();

    // Obtén y muestra la ubicación inicial
    final pos = await geo.Geolocator.getCurrentPosition(desiredAccuracy: geo.LocationAccuracy.high);
    _mostrarPunto(pos);

    // 🔄 Escucha cambios de ubicación en tiempo real
    geo.Geolocator.getPositionStream(
      locationSettings: const geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 10, // cada 10m actualiza
      ),
    ).listen((geo.Position newPos) {
      _actualizarPunto(newPos);
    });
  }

  // =========================================================================
// NUEVO: Función para ruta con MÚLTIPLES puntos
// =========================================================================
Future<void> _mostrarRutaMultiPunto() async {
  if (_polylineAnnotationManager == null) {
    debugPrint('⚠️ El mapa aún no está listo para dibujar la ruta.');
    return;
  }

  const String mapboxAccessToken = AppConfig.mapboxAccessToken;

  // 1. Define una LISTA con todos los puntos de la ruta (origen, paradas y destino)
  final List<Position> puntosDeLaRuta = [
    Position(-103.4542, 25.5428), // 1. Plaza Mayor, Torreón
    Position(-103.4285, 25.5186), // 2. Cristo de las Noas
    Position(-103.3989, 25.5683), // 3. Galerías Laguna
    Position(-103.3820, 25.5653), // 4. Aeropuerto Internacional de Torreón
  ];

  // 2. Convierte la lista de puntos a un string formateado para la URL
  //    Ej: "-103.45,25.54;-103.42,25.51;..."
  final String coordinatesString = puntosDeLaRuta
      .map((p) => '${p.lng},${p.lat}')
      .join(';');

  // 3. Construye la URL para la API
  final String url =
      'https://api.mapbox.com/directions/v5/mapbox/driving/$coordinatesString?geometries=geojson&access_token=$mapboxAccessToken';

  // El resto del código es EXACTAMENTE IGUAL al de la función anterior
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
        lineColor: Colors.deepPurple.value, // Un color diferente para distinguirla
        lineWidth: 6.0,
        lineOpacity: 0.9,
      );

      _rutaActual = await _polylineAnnotationManager?.create(polylineOptions);
    } else {
      debugPrint('Error en la API de Mapbox: ${response.body}');
    }
  } catch (e) {
    debugPrint('Ocurrió un error al obtener la ruta: $e');
  }
  
}
  
  /// 🔹 Muestra el punto por primera vez usando el nuevo método
  Future<void> _mostrarPunto(geo.Position pos) async {
    if (_pointAnnotationManager == null) return;
    
    // 1. Carga los bytes de la imagen desde los assets
    final ByteData bytes = await rootBundle.load("assets/icons/Marker.ico");
    final Uint8List list = bytes.buffer.asUint8List();

    // 2. Crea las opciones para un solo punto
    final pointAnnotationOptions = PointAnnotationOptions(
      geometry: Point(coordinates: Position(pos.longitude, pos.latitude)),
      image: list, // ¡Aquí está la magia! Pasa los bytes directamente.
      iconSize: 0.3,
    );

    // 3. Crea el marcador y guarda su instancia para poder actualizarlo después
    _userMarker = await _pointAnnotationManager!.create(pointAnnotationOptions);
  }

  /// 🔹 Actualiza la posición del punto (esta función no necesita cambios)
  Future<void> _actualizarPunto(geo.Position pos) async {
    // Si el marcador no existe, créalo.
    if (_userMarker == null) {
      await _mostrarPunto(pos);
      return;
    }

    // Si ya existe, solo actualiza su geometría
    _userMarker!.geometry = Point(coordinates: Position(pos.longitude, pos.latitude));
    await _pointAnnotationManager!.update(_userMarker!);

    // Centra suavemente el mapa en la nueva posición
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
              styleUri: MapboxStyles.MAPBOX_STREETS,
            ),
    );
  }
}
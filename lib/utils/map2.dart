import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:practica/config.dart';
import 'package:practica/provider/map_state.dart';
import 'package:provider/provider.dart';

class MainMap2 extends StatefulWidget {
  const MainMap2({super.key});

  @override
  State<MainMap2> createState() => _MainMap2State();
}

class _MainMap2State extends State<MainMap2> {
  CameraOptions? _cameraOptions;
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;
  PointAnnotationManager? _pointAnnotationManagerForUser;
  PolylineAnnotationManager? _polylineAnnotationManager;
  PointAnnotation? _userMarker;
  PolylineAnnotation? _rutaActual;
  bool _mapReady = false;
  bool rutaActiva = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mapState = Provider.of<MapState>(context, listen: false);
      mapState.addListener(_onRutaChanged);
    });
  }

  @override
  void dispose() {
    final mapState = Provider.of<MapState>(context, listen: false);
    mapState.removeListener(_onRutaChanged);
    super.dispose();
  }

  void _onRutaChanged() {
  final mapState = Provider.of<MapState>(context, listen: false);
  if (_mapReady && mapState.coordenadasRuta.isNotEmpty) {
    _mostrarRutaDesdeAPI(mapState.coordenadasRuta);
  }
}


  Future<void> _initializeLocation() async {
    await Permission.locationWhenInUse.request();

    bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    geo.LocationPermission permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.deniedForever ||
        permission == geo.LocationPermission.denied) return;

    geo.Position position = await geo.Geolocator.getCurrentPosition(
      desiredAccuracy: geo.LocationAccuracy.high,
    );

    setState(() {
      _cameraOptions = CameraOptions(
        center: Point(coordinates: Position(position.longitude, position.latitude)),
        zoom: 14.0,
        bearing: 0,
        pitch: 0,//Lo voy a cambiar a 24 despues
      );
    });
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
  }

  void _onMapLoaded(MapLoadedEventData data) async {
    _pointAnnotationManager =
        await _mapboxMap!.annotations.createPointAnnotationManager();
    _polylineAnnotationManager =
        await _mapboxMap!.annotations.createPolylineAnnotationManager();

    setState(() => _mapReady = true);

    // final pos = await geo.Geolocator.getCurrentPosition(
    //   desiredAccuracy: geo.LocationAccuracy.high,
    // );
    // _mostrarPunto(pos);
    _centrarEnUsuario();

    geo.Geolocator.getPositionStream(
      locationSettings: const geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 1,
      ),
    ).listen(_actualizarPunto);

    _onRutaChanged();
  }

  Future<void> _mostrarRutaDesdeAPI(List<Position> paradasRuta) async {
    if (!_mapReady || _polylineAnnotationManager == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ El mapa aún no está listo para dibujar la ruta.'),
        ),
      );
      return;
    }

    if (paradasRuta.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Se necesitan al menos 2 puntos para trazar una ruta.'),
        ),
      );
      return;
    }

    final String coordinatesString =
        paradasRuta.map((p) => '${p.lng},${p.lat}').join(';');

    final String url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/$coordinatesString'
        '?alternatives=true&annotations=distance%2Cduration'
        '&geometries=geojson&language=es&overview=full&steps=true'
        '&access_token=${AppConfig.mapboxAccessToken}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return;

      final data = json.decode(response.body);

      final coordinates = data['routes'][0]['geometry']['coordinates'] as List<dynamic>;
      final paradas = data['waypoints'] as List<dynamic>; 

      // 🔹 Convertir coordenadas a lista de posiciones
        final List<Position> points = coordinates
            .map((coord) => Position(coord[0], coord[1]))
            .toList();

      //final points = coordinates.map((c) => Position(c[0], c[1])).toList();

      // Eliminar ruta previa si existe
      if (_rutaActual != null) {
        await _polylineAnnotationManager!.delete(_rutaActual!);
        _rutaActual = null;
      }

      final polylineOptions = PolylineAnnotationOptions(
        geometry: LineString(coordinates: points),
        lineColor: const Color.fromARGB(255, 0, 152, 240).value,
        lineWidth: 5.5,
        lineOpacity: 0.9,
        lineJoin: LineJoin.ROUND,
        lineBlur: 0.5,
      );

      _rutaActual = await _polylineAnnotationManager!.create(polylineOptions);

      if (paradas.isNotEmpty){

        if (_pointAnnotationManager != null) {
          await _mapboxMap!.annotations.removeAnnotationManager(_pointAnnotationManager!);
          _pointAnnotationManager = await _mapboxMap!.annotations.createPointAnnotationManager();

        }

        final ByteData bytes = await rootBundle.load("assets/icons/Marker.ico");
        final Uint8List list = bytes.buffer.asUint8List();

        for (var punto in paradas){
          final location = punto['location'];
          final name = punto['name'];
          await _pointAnnotationManager?.create(PointAnnotationOptions(
            geometry: Point(coordinates: Position(location[0], location[1])),
            image: list,
            iconSize: 0.25,
            textField: name,
            textOffset: [0, 1.5],
            textColor: Colors.white.value,
            textHaloColor: Colors.black.value,
            textHaloWidth: 1.2
          ));
        }
      }
      

      // Centrar cámara
      if (points.isNotEmpty && _mapboxMap != null) {
        final minLng = points.map((p) => p.lng).reduce((a, b) => a < b ? a : b);
        final maxLng = points.map((p) => p.lng).reduce((a, b) => a > b ? a : b);
        final minLat = points.map((p) => p.lat).reduce((a, b) => a < b ? a : b);
        final maxLat = points.map((p) => p.lat).reduce((a, b) => a > b ? a : b);

        final bounds = CoordinateBounds(
          southwest: Point(coordinates: Position(minLng, minLat)),
          northeast: Point(coordinates: Position(maxLng, maxLat)),
          infiniteBounds: false,
        );
  
        final camera = await _mapboxMap!.cameraForCoordinateBounds(
          bounds,
          MbxEdgeInsets(top: 100, left: 100, bottom: 100, right: 100),
          0.0,
          0.0,
          null,
          null,
        );

        await _mapboxMap!.flyTo(camera, MapAnimationOptions(duration: 2000));
      }

    } catch (e) {
      debugPrint("Error al obtener ruta: $e");
    }
  }

  void centrarMyLocation(){
    _centrarEnUsuario();
  }

  Future<void> _centrarEnUsuario() async {
    if (_mapboxMap == null) return;

    try {
      rutaActiva = true;
      final geo.Position pos = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );

      //Creo el punto si no esta hecho
      if (_pointAnnotationManagerForUser == null) {
        _pointAnnotationManagerForUser = await _mapboxMap!.annotations.createPointAnnotationManager();
        final ByteData bytes = await rootBundle.load("assets/icons/Marker.ico");
        final Uint8List list = bytes.buffer.asUint8List();

        final options = PointAnnotationOptions(
          geometry: Point(coordinates: Position(pos.longitude, pos.latitude)),
          image: list,
          iconSize: 0.3,
        );

        _userMarker = await _pointAnnotationManagerForUser!.create(options);
      }


      

      _mapboxMap!.flyTo(
        CameraOptions(
          center: Point(coordinates: Position(pos.longitude, pos.latitude)),
          zoom: 14.0,
          
        ),
        MapAnimationOptions(duration: 1000),
      );
    } catch (e) {
      debugPrint("Error al centrar en usuario: $e");
    }
  }

  Future<void> _actualizarPunto(geo.Position pos) async {
    if(rutaActiva) return;

    if (_userMarker == null) {
      await _centrarEnUsuario();
      return;
    }

    _userMarker!.geometry = Point(coordinates: Position(pos.longitude, pos.latitude));
    await _pointAnnotationManager!.update(_userMarker!);

    _mapboxMap?.flyTo(
      CameraOptions(center: Point(coordinates: Position(pos.longitude, pos.latitude))),
      MapAnimationOptions(duration: 1000),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapState>(
      builder: (context, mapState, child) {
        return Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
          floatingActionButton: FloatingActionButton(
            onPressed: _centrarEnUsuario,
            tooltip: 'Mi Ubicación',
            child: const Icon(Icons.my_location),
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
      },
    );
  }
}

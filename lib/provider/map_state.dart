import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;

class MapState extends ChangeNotifier {
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManagerForUser;
  PointAnnotationManager? _pointAnnotationManagerForPoint;
  PointAnnotation? _userMarker;
  PointAnnotation? _pointMarker;
  bool rutaActiva = false;

  void setMap(MapboxMap map) {
    _mapboxMap = map;
  }

  // 🔹 Guardar coordenadas de una ruta
  List<Position> _coordenadasRuta = [];
  List<Position> get coordenadasRuta => _coordenadasRuta;

  void setRuta(List<Position> coords) {
    _coordenadasRuta = coords;
    notifyListeners();
  }

  // 🔹 Centrar en usuario
  Future<void> centrarEnUsuario() async {
    if (_mapboxMap == null) return;

    try {
      rutaActiva = true;
      final geo.Position pos = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );

      //Creo el punto si no esta hecho
      if (_pointAnnotationManagerForUser == null) {
        _pointAnnotationManagerForUser =
            await _mapboxMap!.annotations.createPointAnnotationManager();
        final ByteData bytes = await rootBundle.load(
          "assets/icons/MarkerUbiRed.png",
        );
        final Uint8List list = bytes.buffer.asUint8List();

        final options = PointAnnotationOptions(
          geometry: Point(coordinates: Position(pos.longitude, pos.latitude)),
          image: list,
          iconSize: 0.15,
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

  Future<void> centrarEnPunto(double lat, double lon) async {
    if (_mapboxMap == null) return;

    try {
      // Inicializar el PointAnnotationManager si no existe
      _pointAnnotationManagerForPoint ??=
          await _mapboxMap!.annotations.createPointAnnotationManager();

      // Eliminar marcador anterior si existe
      if (_pointMarker != null) {
        await _pointAnnotationManagerForPoint!.delete(_pointMarker!);
        _pointMarker = null;
      }

      // Cargar icono
      final ByteData bytes = await rootBundle.load(
        "assets/icons/MarkerUbi.png",
      );
      final Uint8List list = bytes.buffer.asUint8List();

      // Crear nuevo marcador
      final options = PointAnnotationOptions(
        geometry: Point(coordinates: Position(lon, lat)), // longitud primero
        image: list,
        iconSize: 0.15,
      );

      _pointMarker = await _pointAnnotationManagerForPoint!.create(options);

      // Centrar cámara
      _mapboxMap!.flyTo(
        CameraOptions(
          center: Point(coordinates: Position(lon, lat)),
          zoom: 14.0,
        ),
        MapAnimationOptions(duration: 1000),
      );
    } catch (e) {
      debugPrint("Error al centrar en punto: $e");
    }
  }
}

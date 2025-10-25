import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapState extends ChangeNotifier {
  List<Position> _coordenadasRuta = [];
  List<Position> get coordenadasRuta => _coordenadasRuta;

  void setRuta(List<Position> coords) {
    _coordenadasRuta = coords;
    notifyListeners();
  }
}

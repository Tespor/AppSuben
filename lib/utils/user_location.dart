import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  /// Obtiene la ubicación actual del dispositivo, solicitando permisos si es necesario.
  /// Retorna un objeto [Position] o `null` si falla o el usuario no concede permisos.
  static Future<geo.Position?> getCurrentLocation() async {
    try {
      // Solicitar permiso
      final status = await Permission.locationWhenInUse.request();

      if (status.isDenied || status.isPermanentlyDenied) {
        print('Permiso de ubicación denegado.');
        return null;
      }

      // Verificar si el servicio de ubicación está habilitado
      final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('El servicio de ubicación está deshabilitado.');
        return null;
      }

      // Verificar permisos
      final permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied || permission == geo.LocationPermission.deniedForever) {
        print('Permiso de ubicación no concedido.');
        return null;
      }

      // Obtener ubicación
      final position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      print('Error al obtener la ubicación: $e');
      return null;
    }
  }
}

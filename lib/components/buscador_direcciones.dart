import 'package:practica/utils/user_location.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:practica/config.dart';
import 'package:practica/config.dart';


class Buscador extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChange;

  const Buscador({
    super.key,
    required this.controller,
    this.hintText = '¿A donde te gustaría ir?',
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChange,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: hintText,
          labelStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
            height: 1.5,
            fontWeight: FontWeight.w900,
            //fontFamily: 'Poppins',
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: TemaColores.primary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide:
                const BorderSide(color: Color.fromARGB(45, 158, 158, 158)),
          ),
          prefixIcon: Icon(Icons.search, color: TemaColores.primary),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        style: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          height: 1.5,
        ),
      ),
    );
  }
}

// Future<void> getData() async {
//   final url = Uri.parse('http://192.168.1.12:2025/practica2/all');

//   try {
//     final response = await http.get(url);
//     print(response.body);
//   } catch (e) {
//     print("Error: $e");
//   }
// }

/// Busca direcciones relacionadas con el texto proporcionado.
/// Retorna una lista de mapas con el nombre y las coordenadas de cada dirección.

Future<List<Map<String, String>>> buscarDireccion(String texto) async {
  final position = await LocationService.getCurrentLocation();

  if (position == null) {
    return [
      {"place_name": "Concede permisos de localización", "center": ""}
    ];
  }

  // Rango en grados (100 km ≈ 0.9 grados)
  double rango = 0.9;
  // Coordenadas de la bounding box
  double minLon = position.longitude - rango;
  double maxLon = position.longitude + rango;
  double minLat = position.latitude - rango;
  double maxLat = position.latitude + rango;

  final url = Uri.parse(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/${Uri.encodeComponent(texto)}.json'
      '?access_token=${AppConfig.mapboxAccessToken}'
      '&autocomplete=true'
      '&limit=15'
      '&language=es'
      '&proximity=${position.longitude},${position.latitude}'
      '&bbox=$minLon,$minLat,$maxLon,$maxLat'
      //'&country=MX'
      //'&types=address,poi,locality,neighborhood,place'
      //'&fuzzyMatch=true'
      );
  print('&bbox=$minLon,$minLat,$maxLon,$maxLat');

  try {
    final respuesta = await http.get(url);

    if (respuesta.statusCode == 200) {
      final data = json.decode(respuesta.body);
      final List features = data['features'];

      return features.map<Map<String, String>>((item) {
        final name = item['place_name'] as String;
        final center = item['center'];
        final centerStr = center != null ? '${center[0]}, ${center[1]}' : '';
        return {
          'place_name': name,
          'center': centerStr,
        };
      }).toList();
    } else {
      print('Error: ${respuesta.statusCode}');
      return [];
    }
  } catch (e) {
    print('Error al buscar las direcciones relacionadas: $e');
    return [];
  }
}

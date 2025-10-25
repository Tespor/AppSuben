
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:practica/provider/map_state.dart';
import 'package:provider/provider.dart';

/// Ejemplo de lista de puntos de una ruta
List<Position> matamorosParadas = [
  Position(-103.452000, 25.538000), // Terminal Matamoros
  Position(-103.440000, 25.535000), // Av. Morelos
  Position(-103.430000, 25.530000), // Calle Juárez
  Position(-103.420000, 25.525000), // Blvd. Independencia
  Position(-103.410000, 25.520000), // Calle Victoria
  Position(-103.400000, 25.515000), // Blvd. Revolución
  Position(-103.390000, 25.510000), // Sector residencial
  Position(-103.380000, 25.505000), // Parque Matamoros
  Position(-103.370000, 25.500000), // Escuela
  Position(-103.360000, 25.495000), // Centro comercial
  Position(-103.350000, 25.490000), // Hospital
  Position(-103.340000, 25.485000), // Terminal final
];



List<Position> doradaParadas = [
  Position(-103.457085, 25.535664), // Plaza Mayor
  Position(-103.415266, 25.535454), // Av. Morelos
  Position(-103.415373, 25.516417), // Calle Zaragoza
  Position(-103.399957, 25.507590), // Blvd. Independencia
  Position(-103.375912, 25.534909), // Blvd. Revolución
  Position(-103.316734, 25.534402), // Blvd. Diagonal Reforma
  Position(-103.320196, 25.548847), // Aeropuerto
  Position(-103.330500, 25.550000), // Sector residencial
  Position(-103.350000, 25.540000), // Centro comercial
  Position(-103.365000, 25.545000), // Universidad
  Position(-103.380000, 25.555000), // Hospital
  Position(-103.400000, 25.560000), // Parque
  Position(-103.420000, 25.570000), // Terminal
];


class ListaRutas extends StatelessWidget {

  const ListaRutas({super.key});

  final List<String> rutas = const [
    "Matamoros - Centro",
    "Dorada - Normal",
    "Matamoros - Galeme",
    "Dorada - Merced",
    "Triangulo Amarillo",
    "Triangulo Rojo",
    "Panteones",
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: rutas.length,
      itemBuilder: (context, index) {
        return ListCamion(
          ruta: rutas[index],
          onTap: () {
            var paradas;
            final mapState = Provider.of<MapState>(context, listen: false);
            if (index == 0){
              paradas = matamorosParadas;
            }
            else {
              paradas = doradaParadas;
            }
            mapState.setRuta(paradas);
            // Opcional: cerrar menú si quieres
          },
        );
      },
    );
  }
}

/// Widget individual que representa una tarjeta de una ruta
class ListCamion extends StatelessWidget {
  final String ruta;
  final VoidCallback? onTap;

  const ListCamion({
    super.key,
    required this.ruta,
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    const colorAzul = Color.fromARGB(255, 10, 172, 228);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 14),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white30,
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            splashColor: Colors.blue.shade200,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [colorAzul, Colors.blue],
                      ),
                    ),
                    child: const Icon(
                      Icons.directions_bus,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      ruta,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        shadows: [
                          Shadow(
                            color: Colors.white,
                            offset: Offset(0, 0),
                            blurRadius: 90,
                          )
                        ],
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black26,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

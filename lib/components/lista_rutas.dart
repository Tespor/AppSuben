import 'package:flutter/material.dart';
import 'dart:ui';

class ListaRutas extends StatelessWidget {
  const ListaRutas({super.key});

  final List<String> rutas = const [
    "Matamoros - Centro",
    "Matamoros - Galeme",
    "Dorada - Merced",
    "Dorada - Normal",
    "Triangulo Amarillo",
    "Triangulo Rojo",
    "Panteones",
    "Matamoros - Centro",
    "Matamoros - Galeme",
    "Dorada - Merced",
    "Dorada - Normal",
    "Triangulo Amarillo",
    "Triangulo Rojo",
    "Panteones",
    "Matamoros - Centro",
    "Matamoros - Galeme",
    "Dorada - Merced",
    "Dorada - Normal",
    "Triangulo Amarillo",
    "Triangulo Rojo",
    "Panteones",
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: rutas.length,
      itemBuilder: (context, index) {
        // Pasamos directamente la ruta al ListCamion
        return ListCamion(ruta: rutas[index]);
      },
    );
  }
}

class ListCamion extends StatelessWidget {
  const ListCamion({super.key, required this.ruta});

  final String ruta; // solo la ruta correspondiente

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  print('Ruta seleccionada: $ruta');
                },
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.directions_bus,
                        color: Colors.white,
                        size: 28,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          ruta,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white54,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

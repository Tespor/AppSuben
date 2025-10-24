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
    final colorAzul = Color.fromARGB(255, 10, 172, 228);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color.fromARGB(20, 31, 58, 80),
            width: 2,
          )
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white30,
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
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            colorAzul,
                            Colors.blue
                          ]
                        )
                      ),
                      child: Icon(
                        Icons.directions_bus,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        ruta,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          shadows: [
                            BoxShadow(
                              color: Colors.white,
                              offset: Offset(0, 0),
                              blurRadius: 90
                            )
                          ]
                        ),
                      ),
                    ),
                    Icon(
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:practica/config.dart';
import 'package:practica/provider/map_state.dart';
import 'package:practica/utils/map.dart';
import 'package:practica/utils/map2.dart';
import 'package:practica/components/buscador_direcciones.dart';
import 'package:provider/provider.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({
    super.key,
  });

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> with WidgetsBindingObserver {
  final TextEditingController controller = TextEditingController();
  List<Map<String, String>> resultados = []; // lista de direcciones encontradas

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  void buscarDirecciones(String texto) async {
    if (texto.isEmpty) {
      setState(() => resultados = []);
      return;
    }
    final res = await buscarDireccion(texto); // tu función del buscador
    setState(() => resultados = res);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: MainMap2(),
        ),
        Positioned.fill(
          child: Stack(
            children: [
              Positioned(
                right: 16,
                bottom: MediaQuery.of(context).size.height * 0.3 + 10,
                child: FloatingActionButton(
                  onPressed: () {
                    Provider.of<MapState>(context, listen: false).centrarEnUsuario();
                  },
                  tooltip: 'Mi Ubicación',
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.my_location, color: TemaColores.primary),
                ),
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.3,
                minChildSize: 0.3,
                maxChildSize: 0.7,
                builder: (context, scrollController) {
                  return Material(
                    color: Colors.white,
                    elevation: 0,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 100,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade400,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),
                          ConductorCard(
                            nombre: 'Juan Pérez',
                            fotoUrl: 'https://i.pravatar.cc/150?img=3',
                            horaEstim: '12:30 pm',
                            calificacion: 4.8,
                            onPressed: () {
                              print('Botón Suben presionado');
                            },
                          ),
                          Buscador(
                            controller: controller,
                            onChange: buscarDirecciones,
                          ),
                          SizedBox(
                            height: 350,
                            child: ListView.builder(
                              controller: scrollController,
                              itemCount: resultados.length,
                              itemBuilder: (context, index) {
                                final item = resultados[index];
                                return ListTile(
                                  title: Text(item['place_name'] ?? 'Sin nombre'),
                                  leading: const Icon(
                                    Icons.location_on,
                                    color: TemaColores.primary,
                                    size: 29,
                                    ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    ),
                                  onTap: () {
                                    final center = item['center'];
                                      if (center != null) {
                                        final coords = center.split(', ');
                                        if (coords.length == 2) {
                                          final lon = double.tryParse(coords[0]);
                                          final lat = double.tryParse(coords[1]);
                                          if (lon != null && lat != null) {
                                            Provider.of<MapState>(context, listen: false).centrarEnPunto(lat, lon);
                                          }
                                        }
                                      }
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
            ],
          ),
        ),
      ],
    );
  }
}

class ContentTextBackground extends StatelessWidget {
  const ContentTextBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: Center(
        child: const Text(
          "HELLO FLUTTER",
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class HeaderApp extends StatelessWidget {
  const HeaderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class ConductorCard extends StatelessWidget {
  final String nombre;
  final String fotoUrl;
  final String horaEstim;
  final double calificacion;
  final VoidCallback onPressed;

  const ConductorCard({
    super.key,
    required this.nombre,
    required this.fotoUrl,
    required this.horaEstim,
    required this.calificacion,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          // Foto del conductor
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.network(
              fotoUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hora estimada: $horaEstim',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      calificacion.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Botón
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: TemaColores.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'SUBEN',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
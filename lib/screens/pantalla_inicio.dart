import 'package:flutter/material.dart';
import 'package:practica/config.dart';
import 'package:practica/utils/map.dart';
import 'package:practica/utils/map2.dart';
import 'package:practica/components/buscador_direcciones.dart';

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
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            child: Buscador(
                              controller: controller,
                              onChange: buscarDirecciones,
                            ),
                          ),
                          SizedBox(
                            height: 480,
                            child: ListView.builder(
                              controller: scrollController,
                              itemCount: resultados.length,
                              itemBuilder: (context, index) {
                                final item = resultados[index];
                                return ListTile(
                                  title: Text(item['place_name'] ?? 'Sin nombre'),
                                  leading: const Icon(Icons.location_on_outlined),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () {
                                    final coords = item['center']?.split(', ');
                                    if (coords != null && coords.length == 2) {
                                      final lon = coords[0];
                                      final lat = coords[1];
                                      print('Coordenadas: $lon, $lat');
                                      // Aquí puedes agregar lógica para agregar marcador en el mapa si quieres
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
              Positioned(
                right: 16,
                bottom: MediaQuery.of(context).size.height * 0.3 + 10,
                child: FloatingActionButton(
                  onPressed: () {
                    print("Centrar en mi ubicación");
                  },
                  tooltip: 'Mi Ubicación',
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.my_location, color: TemaColores.primary),
                ),
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

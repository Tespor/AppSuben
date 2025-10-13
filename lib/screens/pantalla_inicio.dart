import 'package:flutter/material.dart';
import 'package:practica/utils/map.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({
    super.key,
  });

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> with WidgetsBindingObserver {

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // MapboxMap with initialization in the center location
        Positioned.fill(
          child: MainMap()
          ),
        //Boton del menu
        Positioned(
          top: 35,
          left: 15,
          child: FloatingActionButton(
            mini: true,
            onPressed: () => null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(60),
            ),
            backgroundColor: Colors.white,
            child: Icon(Icons.menu, color: Colors.blue, size: 30),
          ),
        ),
        Positioned.fill(
          child: DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.3,
            maxChildSize: 0.7,
            builder: (context, scrollController) {
              return Material(
                color: Colors.white,
                elevation: 0,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
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
                        padding: const EdgeInsets.only(
                          left: 18,
                          right: 18,
                          top: 28,
                        ),
                        child: Text(
                          "¿A donde vas?",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 0),
                      Container(
                        height: 480,
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: 20,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text("Item $index"),
                              subtitle: Text("Subtitle $index"),
                              leading: Icon(Icons.location_on_outlined),
                              trailing: Icon(Icons.arrow_forward_ios),
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

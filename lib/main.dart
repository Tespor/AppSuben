import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:practica/components/btn_menu.dart';
import 'package:practica/components/lista_rutas.dart';
import 'package:practica/config.dart';
import 'package:practica/screens/pantalla_inicio.dart';
import 'package:flutter/services.dart';
import 'package:practica/utils/map.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Configurar StatusBar transparente y texto oscuro o claro
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // transparente
    statusBarIconBrightness: Brightness.dark, // íconos oscuros
    statusBarBrightness: Brightness.light, // para iOS
    systemNavigationBarColor: Colors.transparent, // barra de navegación (si quieres)
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  MapboxOptions.setAccessToken(AppConfig.mapboxAccessToken);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: Scaffold(body: MainMap()),
    );
  }
}

class WidgetBody extends StatefulWidget {
  const WidgetBody({super.key});

  @override
  State<WidgetBody> createState() => _WidgetBodyState();
}

class _WidgetBodyState extends State<WidgetBody> {
  double _startX = 0.0;
  double _offsetX = 0; // valor actual
  double _targetOffset = 0; // destino de la animación
  bool _isAnimating = false;
  bool estadoMenu = false;

  void _toggleMenu(bool abrir) {
    setState(() {
      // Bloquea gestos durante animación
      _isAnimating = true;

      // Determina destino
      _targetOffset = abrir ? 264 : 0;
      estadoMenu = abrir;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        //Fondo Menu
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.cyan
                ],
                stops: [
                  0.5,
                  1
                ]
                ),
              image: DecorationImage(
                image: AssetImage('assets/img/BgMenu2.jpg'),
                fit: BoxFit.cover
                )  
            ),
            child: IgnorePointer(
              ignoring: estadoMenu == false,
              child: SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: EdgeInsets.only(top: 14),
                    width: AppConfig.medidaMenu + 25,
                    child: Material(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              //Icono user
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white70,
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.black54,
                                  size: 28,
                                ),
                              ),
                  
                              //Logo mamalon
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.only(right: 12),
                                  child: Image.asset(
                                    'assets/img/LogoTextMaxBlanco.png',
                                    height: 50,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Expanded(child: ListaRutas()),
                        ],
                      )
                      )
                  ),
                ),
              )
            ),
          ),
        //Mapa
        GestureDetector(
          // Deshabilita gestos si está animando
          onPanStart:
              _isAnimating
                  ? null
                  : (details) {
                    _startX = details.globalPosition.dx;
                  },
          onPanUpdate:
              _isAnimating
                  ? null
                  : (details) {
                    double dx = details.globalPosition.dx - _startX;

                    if (dx < 0) {
                      // deslizar hacia la izquierda
                      setState(() {
                        _offsetX = (264 + dx).clamp(0.0, 264.0);
                        _targetOffset = _offsetX;
                      });
                    }
                  },
          onPanEnd:
              _isAnimating
                  ? null
                  : (details) {
                    setState(() {
                      _targetOffset = _offsetX < 132 ? 0 : 264;
                      _isAnimating = true; // bloquear gestos mientras animamos
                      estadoMenu = _targetOffset == 264;
                    });
                  },
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: _offsetX, end: _targetOffset),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            onEnd: () {
              // cuando la animación termine, habilitamos de nuevo los gestos
              setState(() {
                _isAnimating = false;
                _offsetX = _targetOffset;
              });
            },
            builder: (context, value, child) {
              double scale = 0.85 + (264 - value) / 264 * 0.15;
              double rotationY = 30 * (value / 264);

              return Transform(
                alignment: Alignment.center,
                transform:
                    Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(rotationY * 3.1416 / 180),
                child: Transform.translate(
                  offset: Offset(value, 0),
                  child: Transform.scale(scale: scale, child: child),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 15,
                    spreadRadius: 5,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: PantallaInicio(),
              ),
            ),
          ),
        ),

        //Boton Menu
        MenuBtn(
          isOpen: estadoMenu,
          onMenuToggle: () => _toggleMenu(!estadoMenu),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:practica/config.dart';
import 'package:practica/screens/pantalla_inicio.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: Scaffold(body: WidgetBody()),
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
  double _offsetX = 264;      // valor actual
  double _targetOffset = 264; // destino de la animación
  bool _isAnimating = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Deshabilita gestos si está animando
      onPanStart: _isAnimating ? null : (details) {
        _startX = details.globalPosition.dx;
      },
      onPanUpdate: _isAnimating ? null : (details) {
        double dx = details.globalPosition.dx - _startX;

        if (dx < 0) { // deslizar hacia la izquierda
          setState(() {
            _offsetX = (264 + dx).clamp(0.0, 264.0);
            _targetOffset = _offsetX;
          });
        }
      },
      onPanEnd: _isAnimating ? null : (details) {
        setState(() {
          _targetOffset = _offsetX < 132 ? 0 : 264;
          _isAnimating = true; // bloquear gestos mientras animamos
        });
      },
      child: SizedBox.expand(
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: _offsetX, end: _targetOffset),
          duration: const Duration(milliseconds: 150),
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
              transform: Matrix4.identity()
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
              color: Colors.white,
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
    );
  }
}

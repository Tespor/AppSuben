import 'dart:math';
import 'package:flutter/material.dart';
import 'package:practica/config.dart';

class MenuBtn extends StatelessWidget {
  final bool isOpen;
  final void Function() onMenuToggle;

  const MenuBtn({super.key, required this.isOpen, required this.onMenuToggle});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:
          isOpen
              ? SizedBox(
                width: double.infinity,
                child: Align(
                  alignment: Alignment.topRight, // esquina superior derecha
                  child: Container(
                    margin: const EdgeInsets.all(16), // margen desde bordes
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.arrow_forward_ios),
                        color: Colors.black26,
                        iconSize: 24,
                        onPressed: () {
                          onMenuToggle();
                        },
                        ),
                    ),
                  ),
                ),
              )
              : GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  onMenuToggle();
                },
                child: Container(
                  height: 55,
                  margin: const EdgeInsets.only(left: 18, top: 18),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  constraints: BoxConstraints(
                    minWidth: 40,
                    maxWidth: AppConfig.medidaMenu,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(46, 0, 0, 0),
                        offset: Offset(0, 3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "RUTAS",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Transform.rotate(
                        angle: 45 * pi / 180,
                        child: Icon(
                          Icons.route,
                          color:
                              Colors
                                  .blue, //Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}

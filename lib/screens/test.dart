import 'package:flutter/material.dart';

class TestImage extends StatelessWidget {
  const TestImage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Image(
          image: AssetImage('assets/img/Logo.png'),
          height: 150,
        ),
      ),
    );
  }
}

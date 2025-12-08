import 'package:flutter/material.dart';
import 'package:pioneer/pioneer.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final calc = Calculator();
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(calc.addOne(10).toString()),
        ),
      ),
    );
  }
}

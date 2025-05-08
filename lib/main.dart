import 'package:flutter/material.dart';
import 'CovidDataTableScreen.dart'; // Cambia el nombre si usas otro archivo

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'COVID Tracker Table',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CovidDataTableScreen(),
    );
  }
}

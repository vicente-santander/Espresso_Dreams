import 'package:flutter/material.dart';
import 'package:espresso_dreams/pages/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false, // Desactiva el banner de depuración
      home:
          const SplashScreen(), // Muestra la pantalla de presentación al inicio
    );
  }
}

import 'package:flutter/material.dart';
import 'package:espresso_dreams/pages/my_home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHomePage();
  }

  Future<void> _navigateToHomePage() async {
    // Simula un tiempo de carga
    await Future.delayed(const Duration(seconds: 5));

    // Verifica si el widget aún está montado antes de usar el BuildContext
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MyHomePage(title: 'Inicio'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo de la pantalla de presentación
      body: Center(
        child: Image.asset(
          'assets/icons/espresso_dreams.png',
          width: 250, // Ajusta el tamaño del logo
          height: 250,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:espresso_dreams/pages/my_home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  double _opacity = 1.0; // Inicialmente opacidad completa

  @override
  void initState() {
    super.initState();
    _startFadeOut();
    _navigateToHomePage();
  }

  Future<void> _startFadeOut() async {
    // Espera unos segundos antes de iniciar el desvanecimiento
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      // Cambia la opacidad a 0.0 para hacer que la imagen se desvanezca
      _opacity = 0.0;
    });
  }

  Future<void> _navigateToHomePage() async {
    // Simula un tiempo de carga total (incluyendo el tiempo de desvanecimiento)
    await Future.delayed(const Duration(seconds: 3));

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
        child: AnimatedOpacity(
          opacity: _opacity, // Opacidad controlada por el estado
          duration: const Duration(
              seconds: 1), // Duración de la animación de desvanecimiento
          child: Image.asset(
            'assets/icons/espresso_dreams.png',
            width: 250, // Ajusta el tamaño del logo
            height: 250,
          ),
        ),
      ),
    );
  }
}

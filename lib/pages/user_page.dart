import 'package:espresso_dreams/pages/saved_recipes_page.dart';
import 'package:espresso_dreams/pages/my_recipes_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Importa el paquete para SVG

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil del Usuario'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/9041988_user_male_icon.svg',
                width: 160,
                height: 160,
              ),
              const SizedBox(height: 16),
              const Text(
                'Nombre del Usuario',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'email@example.com',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SavedRecipesPage()));
                },
                child: const Text('Recetas guardadas'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyRecipesPage()));
                },
                child: const Text('Mis recetas'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Acción del botón (por ejemplo, editar perfil)
                },
                child: const Text('vender productos'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

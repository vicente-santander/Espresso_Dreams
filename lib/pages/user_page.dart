import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Usuario {
  final String nombre;
  final String correo;
  final int numeroDeRecetas;
  final double promedioDeRecetas;

  Usuario({
    required this.nombre,
    required this.correo,
    required this.numeroDeRecetas,
    required this.promedioDeRecetas,
  });
}

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  // Crea un usuario de ejemplo
  Usuario usuario = Usuario(
    nombre: 'Usuario X',
    correo: 'email@example.com',
    numeroDeRecetas: 5,
    promedioDeRecetas: 4.5,
  );

  void _editUser() {
    // Método para editar la información del usuario
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String nuevoNombre = usuario.nombre;
        String nuevoCorreo = usuario.correo;

        return AlertDialog(
          title: const Text('Editar Información'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Nombre'),
                onChanged: (value) {
                  nuevoNombre = value;
                },
                controller: TextEditingController(text: usuario.nombre),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  usuario = Usuario(
                    nombre: nuevoNombre,
                    correo: nuevoCorreo,
                    numeroDeRecetas: usuario.numeroDeRecetas,
                    promedioDeRecetas: usuario.promedioDeRecetas,
                  );
                });
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

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
              Text(
                usuario.nombre,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                usuario.correo,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Número de recetas: ${usuario.numeroDeRecetas}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Promedio de recetas: ${usuario.promedioDeRecetas}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _editUser,
                child: const Text('Editar Información'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

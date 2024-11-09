import 'dart:io';
import 'package:espresso_dreams/utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:espresso_dreams/pages/user_page.dart';
import 'package:espresso_dreams/pages/recipes_page.dart';
import 'package:espresso_dreams/pages/saved_recipes_page.dart';
import 'package:espresso_dreams/pages/my_recipes_page.dart';
import 'package:espresso_dreams/models/recipe_class.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isFavorite = false;
  Recipe? mostViewedRecipe; // Declaración de la receta más vista

  @override
  void initState() {
    super.initState();
    _loadLastRecipe();
  }

  void _loadLastRecipe() async {
    Recipe lastRecipe = await DatabaseHelper().getLastRecipe();
    setState(() {
      mostViewedRecipe = lastRecipe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 100,
              color: Colors.yellow[200],
              child: const DrawerHeader(
                child: Text(
                  'Espresso Dreams',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            ListTile(
              leading: SvgPicture.asset(
                'assets/icons/9041988_user_male_icon.svg',
                width: 24,
                height: 24,
              ),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Recetas'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecipesPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Recetas favoritas'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SavedRecipesPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Mis recetas'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyRecipesPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Card para la receta más vista
            Card(
              margin: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: mostViewedRecipe == null
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'La receta más nueva',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            mostViewedRecipe!.name,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 5),
                          // Mostrar la imagen de la receta, si existe
                          mostViewedRecipe!.image != null
                              ? mostViewedRecipe!.image!.startsWith('assets/')
                                  ? Image.asset(mostViewedRecipe!
                                      .image!) // Si es un recurso (asset)
                                  : Image.file(File(mostViewedRecipe!
                                      .image!)) // Si es una imagen local
                              : const SizedBox.shrink(),
                          const SizedBox(height: 10),
                          Text(
                            'Ingredientes:\n${mostViewedRecipe!.ingredients}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Preparación:\n${mostViewedRecipe!.preparation}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Productos asociados:\n${mostViewedRecipe!.associatedProducts}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Tiempo de preparación: ${mostViewedRecipe!.preparationTime} minutos',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Fecha de creación: ${mostViewedRecipe!.dateCreated}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : null,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isFavorite = !isFavorite;
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.share),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Compartiendo receta'),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

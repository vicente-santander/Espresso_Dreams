import 'dart:io';

import 'package:camera/camera.dart';
import 'package:espresso_dreams/utils/camera_controller.dart';
import 'package:flutter/material.dart';
import 'package:espresso_dreams/models/recipe_class.dart';
import 'package:espresso_dreams/utils/database_helper.dart';

class MyRecipesPage extends StatefulWidget {
  const MyRecipesPage({super.key});

  @override
  State<MyRecipesPage> createState() => _MyRecipesPageState();
}

class _MyRecipesPageState extends State<MyRecipesPage> {
  List<Recipe> savedRecipes = [];
  List<Recipe> filteredRecipes = [];
  List<bool> favoriteStatus = [];
  List<bool> expandedStatus = [];
  final TextEditingController searchController = TextEditingController();
  final DatabaseHelper dbHelper = DatabaseHelper();

  late CameraController _cameraController; // Agregamos el controlador de cámara
  late Future<void>
      // ignore: unused_field
      _initializeCameraFuture; // Variable para manejar la inicialización

  @override
  void initState() {
    super.initState();
    _loadSavedRecipes(); // Cargar recetas desde la base de datos
    searchController.addListener(_filterRecipes);
    _initializeCamera(); // Inicializar la cámara
  }

  Future<void> _initializeCamera() async {
    // Obtén la lista de cámaras disponibles y selecciona la primera cámara.
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    // Crea y guarda una instancia del controlador de cámara.
    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    // Inicializa el controlador de cámara y maneja la excepción si falla.
    _initializeCameraFuture = _cameraController.initialize().catchError((e) {
      // Maneja el error si no se puede inicializar la cámara.
      // ignore: avoid_print
      print('Error al inicializar la cámara: $e');
    });
  }

  Future<void> _loadSavedRecipes() async {
    final recipes = await dbHelper.getRecipes();
    setState(() {
      savedRecipes = recipes.where((recipe) => recipe.isMine).toList();
      filteredRecipes = savedRecipes;
      favoriteStatus = List.generate(
          savedRecipes.length, (index) => savedRecipes[index].isFavorite);
      expandedStatus = List.generate(savedRecipes.length, (_) => false);
    });
  }

  void _filterRecipes() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredRecipes = savedRecipes.where((recipe) {
        return recipe.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _addRecipe() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController ingredientsController = TextEditingController();
    final TextEditingController preparationController = TextEditingController();
    XFile? recipeImage;

    // Obtén la lista de cámaras disponibles y selecciona la primera cámara.
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Nueva Receta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: ingredientsController,
                decoration: const InputDecoration(labelText: 'Ingredientes'),
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
              TextField(
                controller: preparationController,
                decoration: const InputDecoration(labelText: 'Preparación'),
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Tomar Foto'),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TakePictureScreen(camera: firstCamera),
                    ),
                  );

                  if (result != null) {
                    recipeImage = result as XFile;
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Foto capturada')),
                    );
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final newRecipe = Recipe.createNewRecipe(
                  nameController.text,
                  ingredientsController.text,
                  preparationController.text,
                  image: recipeImage?.path,
                );
                newRecipe.isMine = true;
                dbHelper.insertRecipe(newRecipe);
                Navigator.of(context).pop();
                _loadSavedRecipes();
              },
              child: const Text('Agregar'),
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
        title: const Text('Mis Recetas'),
        backgroundColor: const Color.fromARGB(255, 174, 97, 71),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar recetas',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: filteredRecipes.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.coffee,
                                color: Colors.brown[500],
                                size: 40,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      filteredRecipes[index].name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editRecipe(index),
                              ),
                              IconButton(
                                icon: Icon(
                                  favoriteStatus[index]
                                      ? Icons.favorite
                                      : Icons.favorite_border_sharp,
                                  color:
                                      favoriteStatus[index] ? Colors.red : null,
                                  size: 24,
                                ),
                                onPressed: () {
                                  setState(() {
                                    favoriteStatus[index] =
                                        !favoriteStatus[index];
                                    filteredRecipes[index].isFavorite =
                                        favoriteStatus[index];
                                    dbHelper
                                        .updateRecipe(filteredRecipes[index]);
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  expandedStatus[index]
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  size: 24,
                                ),
                                onPressed: () {
                                  setState(() {
                                    expandedStatus[index] =
                                        !expandedStatus[index];
                                  });
                                },
                              ),
                            ],
                          ),
                          if (expandedStatus[index])
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                const Text(
                                  'Ingredientes:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(filteredRecipes[index].ingredients),
                                const SizedBox(height: 8),
                                const Text(
                                  'Preparación:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(filteredRecipes[index].preparation),
                                const SizedBox(height: 16),
                                // Aquí agregamos la imagen de la receta
                                if (filteredRecipes[index].image !=
                                    null) // Verifica si hay una imagen
                                  Image.file(
                                    File(filteredRecipes[index].image!),
                                    height:
                                        200, // Ajusta la altura según lo necesites
                                    fit: BoxFit
                                        .cover, // Ajusta el ajuste según lo necesites
                                  ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Calificaciones:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                _buildRating(index),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRecipe,
        backgroundColor: const Color.fromARGB(255, 174, 97, 71),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _editRecipe(int index) {
    final TextEditingController nameController =
        TextEditingController(text: filteredRecipes[index].name);
    final TextEditingController ingredientsController =
        TextEditingController(text: filteredRecipes[index].ingredients);
    final TextEditingController preparationController =
        TextEditingController(text: filteredRecipes[index].preparation);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Receta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: ingredientsController,
                decoration: const InputDecoration(labelText: 'Ingredientes'),
                maxLines: 3,
              ),
              TextField(
                controller: preparationController,
                decoration: const InputDecoration(labelText: 'Preparación'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  filteredRecipes[index].updateRecipe(
                    newName: nameController.text,
                    newIngredients: ingredientsController.text,
                    newPreparation: preparationController.text,
                  );
                  dbHelper.updateRecipe(filteredRecipes[index]);
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

  Widget _buildRating(int index) {
    double averageRating = filteredRecipes[index].getAverageRating();
    int ratingCount = filteredRecipes[index].getRatingCount();

    return Column(
      children: [
        Text(
          'Promedio: ${averageRating.toStringAsFixed(1)} ($ratingCount calificaciones)',
          style: const TextStyle(fontSize: 14),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (starIndex) {
            return IconButton(
              icon: Icon(
                starIndex < averageRating.floor()
                    ? Icons.star
                    : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () {
                setState(() {
                  filteredRecipes[index].addRating((starIndex + 1).toDouble());
                  dbHelper.updateRecipe(filteredRecipes[index]);
                });
              },
            );
          }),
        ),
      ],
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

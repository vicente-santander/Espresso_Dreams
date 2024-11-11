// ignore_for_file: avoid_print, use_build_context_synchronously
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
// ignore: unnecessary_import
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
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
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    _initializeCameraFuture = _cameraController.initialize().then((_) {
      setState(
          () {}); // Actualiza la interfaz de usuario después de inicializar
    }).catchError((e) {
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

  Future<String?> _saveImageToPersistentStorage(XFile imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final String newPath = '${directory.path}/${imageFile.name}';
      await imageFile.saveTo(newPath);
      return newPath;
    } catch (e) {
      print("Error al guardar la imagen de manera persistente: $e");
      return null;
    }
  }

  Future<void> _addRecipe() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController ingredientsController = TextEditingController();
    final TextEditingController preparationController = TextEditingController();
    final TextEditingController preparationTimeController =
        TextEditingController();
    final TextEditingController associatedProductsController =
        TextEditingController();
    final ValueNotifier<XFile?> recipeImageNotifier =
        ValueNotifier<XFile?>(null);
    final ImagePicker picker = ImagePicker();

    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Nueva Receta'),
          content: SingleChildScrollView(
            child: Column(
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
                TextField(
                  controller: preparationTimeController,
                  decoration: const InputDecoration(
                      labelText: 'Tiempo de preparación (minutos)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: associatedProductsController,
                  decoration:
                      const InputDecoration(labelText: 'Productos asociados'),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.image),
                      label: const Text('Galería'),
                      onPressed: () async {
                        final pickedFile =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          recipeImageNotifier.value = pickedFile;
                        }
                      },
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Cámara'),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TakePictureScreen(camera: firstCamera),
                          ),
                        );
                        if (result != null) {
                          recipeImageNotifier.value = result as XFile;
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<XFile?>(
                  valueListenable: recipeImageNotifier,
                  builder: (context, recipeImage, child) {
                    if (recipeImage != null) {
                      return Column(
                        children: [
                          const SizedBox(height: 8),
                          Image.file(
                            File(recipeImage.path),
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ],
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final String currentDate =
                    DateFormat('yyyy-MM-dd').format(DateTime.now());
                final imagePath = recipeImageNotifier.value != null
                    ? await _saveImageToPersistentStorage(
                        recipeImageNotifier.value!)
                    : null;

                final newRecipe = Recipe.createNewRecipe(
                  nameController.text,
                  ingredientsController.text,
                  preparationController.text,
                  currentDate,
                  int.tryParse(preparationTimeController.text) ?? 0,
                  associatedProductsController.text,
                  imagePath,
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
        backgroundColor: const Color.fromARGB(255, 202, 97, 32),
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
                                      ? Icons.remove_red_eye
                                      : Icons.remove_red_eye_outlined,
                                  color: favoriteStatus[index]
                                      ? Colors.black
                                      : null,
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
                                const SizedBox(height: 8),
                                const Text(
                                  'Productos asociados:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(filteredRecipes[index].associatedProducts),
                                const SizedBox(height: 16),
                                // Verifica si hay una imagen
                                if (filteredRecipes[index].image != null)
                                  _buildImage(filteredRecipes[index].image!),
                                const SizedBox(height: 16),
                                const SizedBox(height: 8),
                                Text(
                                  'Tiempo de preparación: ${filteredRecipes[index].preparationTime} minutos',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color:
                                          Color.fromARGB(255, 106, 106, 106)),
                                ),
                                Text(
                                  'Fechade registro: ${filteredRecipes[index].dateCreated}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color:
                                          Color.fromARGB(255, 106, 106, 106)),
                                ),
                                Text(
                                  'Veces preparada: ${filteredRecipes[index].usageCount}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color:
                                          Color.fromARGB(255, 106, 106, 106)),
                                ),
                                const SizedBox(height: 8),
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

  Widget _buildImage(String? imagePath) {
    if (imagePath == null) {
      return const SizedBox.shrink();
    }

    // Verifica si es una ruta de archivo (local) o una imagen de assets
    bool isAsset = imagePath.startsWith('assets/');

    if (isAsset) {
      // Si la imagen es un asset
      return Image.asset(
        imagePath,
        height: 200,
        fit: BoxFit.cover,
      );
    } else {
      // Si la imagen es un archivo local
      return Image.file(
        File(imagePath),
        height: 200,
        fit: BoxFit.cover,
      );
    }
  }

  Future<void> _editRecipe(int index) async {
    final recipe = filteredRecipes[index];
    final TextEditingController nameController =
        TextEditingController(text: recipe.name);
    final TextEditingController ingredientsController =
        TextEditingController(text: recipe.ingredients);
    final TextEditingController preparationController =
        TextEditingController(text: recipe.preparation);
    final TextEditingController preparationTimeController =
        TextEditingController(text: recipe.preparationTime.toString());
    final TextEditingController associatedProductsController =
        TextEditingController(text: recipe.associatedProducts);

    final ValueNotifier<XFile?> recipeImageNotifier =
        ValueNotifier<XFile?>(null);
    bool isAssetImage =
        recipe.image != null && recipe.image!.startsWith('assets/');

    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Receta'),
          content: SingleChildScrollView(
            child: Column(
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
                TextField(
                  controller: preparationTimeController,
                  decoration: const InputDecoration(
                      labelText: 'Tiempo de preparación (minutos)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: associatedProductsController,
                  decoration:
                      const InputDecoration(labelText: 'Productos asociados'),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.photo),
                      label: const Text('Galería'),
                      onPressed: () async {
                        final pickedFile = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          recipeImageNotifier.value = pickedFile;
                          isAssetImage = false;
                        }
                      },
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Cámara'),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TakePictureScreen(camera: firstCamera),
                          ),
                        );
                        if (result != null) {
                          recipeImageNotifier.value = result as XFile;
                        }
                      },
                    ),
                  ],
                ),
                ValueListenableBuilder<XFile?>(
                  valueListenable: recipeImageNotifier,
                  builder: (context, recipeImage, child) {
                    if (recipeImage != null) {
                      return Column(
                        children: [
                          const SizedBox(height: 8),
                          Image.file(
                            File(recipeImage.path),
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ],
                      );
                    } else if (recipe.image != null) {
                      return _buildImage(recipe.image);
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                String? imagePath;
                if (recipeImageNotifier.value != null) {
                  imagePath = await _saveImageToPersistentStorage(
                      recipeImageNotifier.value!);
                } else if (isAssetImage) {
                  imagePath = recipe.image;
                }

                recipe.updateRecipeImage(
                  newName: nameController.text,
                  newIngredients: ingredientsController.text,
                  newPreparation: preparationController.text,
                  newPreparationTime:
                      int.tryParse(preparationTimeController.text) ?? 0,
                  newAssociatedProducts: associatedProductsController.text,
                  newPath: imagePath,
                );
                await dbHelper.updateRecipe(recipe);

                Navigator.of(context).pop();
                _loadSavedRecipes();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    _cameraController.dispose();
    super.dispose();
  }
}

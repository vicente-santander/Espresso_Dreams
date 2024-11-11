import 'dart:io';

import 'package:flutter/material.dart';
import 'package:espresso_dreams/models/recipe_class.dart';
import 'package:espresso_dreams/utils/database_helper.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart'; // Asegúrate de importar path

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  List<Recipe> recipes = [];
  List<bool> favoriteStatus = []; // Estado de favorito para cada receta
  List<bool> expandedStatus = []; // Estado expandido para cada receta
  List<Recipe> filteredRecipes = []; // Para almacenar las recetas filtradas
  final TextEditingController searchController =
      TextEditingController(); // Controlador para el campo de búsqueda

  @override
  void initState() {
    super.initState();
    Recipe.loadInitialRecipes(DatabaseHelper()).then((_) {
      _loadRecipes();
    });
    searchController.addListener(
        _filterRecipes); // Escuchar cambios en el campo de búsqueda
  }

  Future<void> _loadRecipes() async {
    recipes = await DatabaseHelper()
        .getRecipes(); // Obtener recetas de la base de datos
    setState(() {
      favoriteStatus =
          List.generate(recipes.length, (index) => recipes[index].isFavorite);
      expandedStatus = List.generate(recipes.length, (_) => false);
      filteredRecipes =
          recipes; // Inicialmente, todas las recetas están filtradas
    });
  }

  // Método para filtrar recetas según la consulta de búsqueda
  void _filterRecipes() {
    String query =
        searchController.text.toLowerCase(); // Obtener texto en minúsculas
    setState(() {
      filteredRecipes = recipes.where((recipe) {
        return recipe.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _shareRecipe(Recipe recipe) async {
    String recipeText = '''
      Receta: ${recipe.name}
      
      Ingredientes: 
      ${recipe.ingredients}
      
      Preparación: 
      ${recipe.preparation}
      
      Productos relacionados: 
      ${recipe.associatedProducts}
      
      Tiempo de preparación: ${recipe.preparationTime} minutos
      ''';

    List<XFile> files = [];

    if (recipe.image != null) {
      final String imagePath = recipe.image!;

      if (imagePath.startsWith('assets/')) {
        final ByteData byteData = await rootBundle.load(imagePath);
        final tempDir = await getTemporaryDirectory();
        final filePath = path.join(tempDir.path, path.basename(imagePath));
        final file = File(filePath);
        await file.writeAsBytes(byteData.buffer.asUint8List());
        files.add(XFile(filePath));
      } else {
        files.add(XFile(imagePath));
      }
    }

    if (files.isNotEmpty) {
      await Share.shareXFiles(files, text: recipeText);
    } else {
      await Share.share(recipeText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recetas de Café'),
        backgroundColor: const Color.fromARGB(255, 174, 97, 71),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Campo de búsqueda
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
                itemCount: filteredRecipes.length + 1,
                itemBuilder: (context, index) {
                  if (index == filteredRecipes.length) {
                    return const SizedBox(height: 80);
                  }

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
                                    Text(
                                        'Tiempo de preparación: ${filteredRecipes[index].preparationTime} minutos'),
                                  ],
                                ),
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
                                onPressed: () async {
                                  setState(() {
                                    favoriteStatus[index] =
                                        !favoriteStatus[index];
                                    filteredRecipes[index].isFavorite =
                                        favoriteStatus[index];
                                  });
                                  await DatabaseHelper()
                                      .updateRecipe(filteredRecipes[index]);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.share, size: 24),
                                onPressed: () {
                                  _shareRecipe(filteredRecipes[index]);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 24),
                                onPressed: () {
                                  showEditRecipeDialog(context,
                                      filteredRecipes[index], DatabaseHelper());
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                    expandedStatus[index]
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    size: 24),
                                onPressed: () {
                                  setState(() {
                                    expandedStatus[index] =
                                        !expandedStatus[index];
                                    if (expandedStatus[index]) {
                                      // Llama a incrementUsageCount solo al expandir la receta
                                      filteredRecipes[index]
                                          .incrementUsageCount();
                                    }
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
                                      fontSize: 16),
                                ),
                                Text(filteredRecipes[index].ingredients),
                                const SizedBox(height: 8),
                                const Text(
                                  'Preparación:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Text(filteredRecipes[index].preparation),
                                const SizedBox(height: 8),
                                const Text(
                                  'Productos Asociados:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Text(filteredRecipes[index].associatedProducts),
                                const SizedBox(height: 16),
                                filteredRecipes[index].image != null
                                    ? filteredRecipes[index]
                                            .image!
                                            .startsWith('assets/')
                                        ? Image.asset(
                                            filteredRecipes[index].image!)
                                        : Image.file(
                                            File(filteredRecipes[index].image!))
                                    : const SizedBox.shrink(),
                                const SizedBox(height: 16),
                                Text(
                                  'Fecha de registro: ${filteredRecipes[index].dateCreated}',
                                  style: const TextStyle(
                                      color:
                                          Color.fromARGB(255, 106, 106, 106)),
                                ),
                                Text(
                                  'Veces preparada: ${filteredRecipes[index].usageCount}',
                                  style: const TextStyle(
                                      color:
                                          Color.fromARGB(255, 106, 106, 106)),
                                ),
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
      /*floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await deleteLocalDatabase();
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.delete),
      ),*/
    );
  }

  Future<void> deleteLocalDatabase() async {
    String path = join(await getDatabasesPath(), 'recipes.db');
    Database db = await openDatabase(path);
    await db.close();
    await deleteDatabase(path);
    await _loadRecipes();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Función para mostrar el diálogo de edición
  Future<void> showEditRecipeDialog(
      BuildContext context, Recipe recipe, DatabaseHelper dbHelper) async {
    TextEditingController nameController =
        TextEditingController(text: recipe.name);
    TextEditingController ingredientsController =
        TextEditingController(text: recipe.ingredients);
    TextEditingController preparationController =
        TextEditingController(text: recipe.preparation);
    TextEditingController timeController =
        TextEditingController(text: recipe.preparationTime.toString());
    TextEditingController productsController =
        TextEditingController(text: recipe.associatedProducts);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar receta'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nombre')),
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
                    controller: timeController,
                    decoration: const InputDecoration(
                        labelText: 'Tiempo de preparación (min)')),
                TextField(
                  controller: productsController,
                  decoration:
                      const InputDecoration(labelText: 'Productos asociados'),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                recipe.updateRecipe(
                  newName: nameController.text,
                  newIngredients: ingredientsController.text,
                  newPreparation: preparationController.text,
                  newPreparationTime: int.parse(timeController.text),
                  newAssociatedProducts: productsController.text,
                );

                await dbHelper.updateRecipe(recipe);
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}

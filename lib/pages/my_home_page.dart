import 'dart:io';
import 'package:espresso_dreams/pages/tu_opinion.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';

import 'package:espresso_dreams/utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:espresso_dreams/pages/recipes_page.dart';
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
  List<Recipe> favoriteRecipes = [];
  Recipe? mostViewedRecipe; // Declaración de la receta más vista

  @override
  void initState() {
    super.initState();
    _loadLastRecipe();
    _loadFavoriteRecipes();
  }

  Future<void> _loadLastRecipe() async {
    Recipe lastRecipe = await DatabaseHelper().getLastRecipe();
    setState(() {
      mostViewedRecipe = lastRecipe;
    });
  }

  Future<void> _loadFavoriteRecipes() async {
    List<Recipe> recipes = await DatabaseHelper().getFavoriteRecipes();
    setState(() {
      favoriteRecipes = recipes;
    });
  }

  Future<void> _toggleFavorite(Recipe recipe) async {
    setState(() {
      recipe.isFavorite = !recipe.isFavorite;
      if (!recipe.isFavorite) {
        favoriteRecipes.remove(recipe);
      } else {
        favoriteRecipes.add(recipe);
      }
    });
    await DatabaseHelper().updateRecipe(recipe);
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
              color: const Color.fromARGB(255, 188, 125, 7),
              child: const DrawerHeader(
                child: Text(
                  'Espresso Dreams',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.coffee),
              title: const Text('Barista'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecipesPage(),
                  ),
                ).then((_) {
                  _loadLastRecipe();
                  _loadFavoriteRecipes();
                });
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
                ).then((_) {
                  _loadLastRecipe();
                  _loadFavoriteRecipes();
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.comment),
              title: const Text('Tu opinion'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FeedbackScreen(),
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
            Card(
              margin: const EdgeInsets.all(16.0),
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
                          mostViewedRecipe!.image != null
                              ? mostViewedRecipe!.image!.startsWith('assets/')
                                  ? Image.asset(mostViewedRecipe!.image!)
                                  : Image.file(File(mostViewedRecipe!.image!))
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isFavorite
                                      ? Icons.remove_red_eye
                                      : Icons.remove_red_eye_outlined,
                                  color: isFavorite ? Colors.black : null,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isFavorite = !isFavorite;
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.share),
                                onPressed: () =>
                                    _shareRecipe(mostViewedRecipe!),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Recetas en preparación',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: favoriteRecipes.length,
              itemBuilder: (context, index) {
                final recipe = favoriteRecipes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: ExpansionTile(
                    title: Text(recipe.name),
                    leading: recipe.image != null
                        ? (recipe.image!.startsWith('assets/')
                            ? Image.asset(recipe.image!, width: 50, height: 50)
                            : Image.file(File(recipe.image!),
                                width: 50, height: 50))
                        : const SizedBox(width: 50, height: 50),
                    onExpansionChanged: (expanded) async {
                      if (expanded) {
                        recipe.incrementUsageCount();
                        // Recargar la receta para reflejar el incremento de uso
                        setState(() {});
                      }
                    },
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ingredientes:\n${recipe.ingredients}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Preparación:\n${recipe.preparation}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Productos asociados:\n${recipe.associatedProducts}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tiempo de preparación: ${recipe.preparationTime} minutos',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                            Text(
                              'Veces preparada: ${recipe.usageCount}',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    recipe.isFavorite
                                        ? Icons.remove_red_eye
                                        : Icons.remove_red_eye_outlined,
                                    color:
                                        recipe.isFavorite ? Colors.black : null,
                                  ),
                                  onPressed: () => _toggleFavorite(recipe),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.share),
                                  onPressed: () => _shareRecipe(recipe),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

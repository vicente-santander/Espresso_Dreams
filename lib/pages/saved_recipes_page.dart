import 'package:flutter/material.dart';
import 'package:espresso_dreams/models/recipe_class.dart';
import 'package:espresso_dreams/utils/database_helper.dart';

class SavedRecipesPage extends StatefulWidget {
  const SavedRecipesPage({super.key});

  @override
  State<SavedRecipesPage> createState() => _SavedRecipesPageState();
}

class _SavedRecipesPageState extends State<SavedRecipesPage> {
  List<Recipe> favoriteRecipes = [];
  List<bool> expandedStatus = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFavoriteRecipes(); // Carga las recetas favoritas desde la base de datos
    searchController.addListener(_filterRecipes);
  }

  Future<void> _loadFavoriteRecipes() async {
    final dbHelper = DatabaseHelper();
    List<Recipe> favorites = await dbHelper.getFavoriteRecipes();
    setState(() {
      favoriteRecipes = favorites;
      expandedStatus = List.generate(favoriteRecipes.length, (_) => false);
    });
  }

  void _filterRecipes() {
    String query = searchController.text.toLowerCase();
    setState(() {
      favoriteRecipes = favoriteRecipes.where((recipe) {
        return recipe.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recetas Favoritas'),
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
                itemCount: favoriteRecipes.length + 1,
                itemBuilder: (context, index) {
                  if (index == favoriteRecipes.length) {
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
                                      favoriteRecipes[index].name,
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
                                icon: const Icon(
                                  Icons.share,
                                  size: 24,
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Compartiendo receta'),
                                    ),
                                  );
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
                                Text(favoriteRecipes[index].ingredients),
                                const SizedBox(height: 8),
                                const Text(
                                  'Preparación:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(favoriteRecipes[index].preparation),
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
    );
  }

  Widget _buildRating(int index) {
    double averageRating = favoriteRecipes[index].getAverageRating();
    int ratingCount = favoriteRecipes[index].getRatingCount();

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
                  favoriteRecipes[index].addRating((starIndex + 1).toDouble());
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

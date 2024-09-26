import 'package:flutter/material.dart';

class Recipe {
  final String name;
  final String ingredients;
  final String preparation;
  List<double> ratings; // Lista de calificaciones

  Recipe(this.name, this.ingredients, this.preparation) : ratings = [];
}

class SavedRecipesPage extends StatefulWidget {
  const SavedRecipesPage({super.key});

  @override
  State<SavedRecipesPage> createState() => _SavedRecipesPageState();
}

class _SavedRecipesPageState extends State<SavedRecipesPage> {
  // Lista de recetas guardadas
  List<Recipe> savedRecipes = [
    Recipe(
      'Café Americano',
      '• Agua\n• Café molido',
      '1. Hervir agua\n2. Agregar café molido\n3. Revolver y servir.',
    )..ratings.addAll([5, 5]), // Calificación de 5
    Recipe(
      'Café Latte',
      '• Café expreso\n• Leche caliente\n• Espuma de leche',
      '1. Preparar café expreso.\n2. Agregar leche caliente.\n3. Cubrir con espuma de leche.',
    )..ratings.addAll([5, 5]), // Calificación de 5
    Recipe(
      'Café Mocha',
      '• Café expreso\n• Chocolate caliente\n• Leche\n• Crema batida',
      '1. Preparar café expreso.\n2. Mezclar con chocolate caliente.\n3. Agregar leche y cubrir con crema.',
    ),
  ];

  List<bool> favoriteStatus = [];
  List<bool> expandedStatus = [];
  List<Recipe> filteredRecipes = []; // Para almacenar las recetas filtradas
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    favoriteStatus = List.generate(savedRecipes.length, (_) => true);
    expandedStatus = List.generate(savedRecipes.length, (_) => false);
    filteredRecipes =
        savedRecipes; // Inicialmente, todas las recetas están filtradas
    searchController.addListener(_filterRecipes);
  }

  void _filterRecipes() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredRecipes = savedRecipes.where((recipe) {
        return recipe.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recetas Guardadas'),
        backgroundColor: const Color.fromARGB(255, 174, 97, 71),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Buscador de recetas
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
                                  });
                                },
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
                                const Text(
                                  'Calificaciones:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                _buildRatingSection(index),
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

  Widget _buildRatingSection(int index) {
    double averageRating = savedRecipes[index].ratings.isNotEmpty
        ? savedRecipes[index].ratings.reduce((a, b) => a + b) /
            savedRecipes[index].ratings.length
        : 0.0;
    int ratingCount = savedRecipes[index].ratings.length;

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
                starIndex <
                        averageRating.floor() // Cambiado de round() a floor()
                    ? Icons.star
                    : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () {
                setState(() {
                  savedRecipes[index].ratings.add((starIndex + 1).toDouble());
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

import 'package:flutter/material.dart';

class Recipe {
  String name; // Cambié a variable mutable
  String ingredients;
  String preparation;
  List<double> ratings;

  Recipe(this.name, this.ingredients, this.preparation) : ratings = [];
}

class MyRecipesPage extends StatefulWidget {
  const MyRecipesPage({super.key});

  @override
  State<MyRecipesPage> createState() => _MyRecipesPageState();
}

class _MyRecipesPageState extends State<MyRecipesPage> {
  List<Recipe> savedRecipes = [
    Recipe(
      'Café Americano',
      '• Agua\n• Café molido',
      '1. Hervir agua\n2. Agregar café molido\n3. Revolver y servir.',
    )..ratings.addAll([5, 5]),
    Recipe(
      'Café con Leche',
      '• Café\n• Leche\n• Azúcar (opcional)',
      '1. Preparar café.\n2. Mezclar con leche caliente.\n3. Agregar azúcar si se desea.',
    ),
  ];

  List<bool> favoriteStatus = [];
  List<bool> expandedStatus = [];
  List<Recipe> filteredRecipes = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    favoriteStatus = List.generate(savedRecipes.length, (_) => false);
    expandedStatus = List.generate(savedRecipes.length, (_) => false);
    filteredRecipes = savedRecipes;
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
                maxLines: 3, // Permitir múltiples líneas
              ),
              TextField(
                controller: preparationController,
                decoration: const InputDecoration(labelText: 'Preparación'),
                maxLines: 5, // Permitir múltiples líneas
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  filteredRecipes[index].name = nameController.text;
                  filteredRecipes[index].ingredients =
                      ingredientsController.text;
                  filteredRecipes[index].preparation =
                      preparationController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRecipeDialog,
        backgroundColor: const Color.fromARGB(
            255, 174, 97, 71), // Llama al método para agregar recetas
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddRecipeDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController ingredientsController = TextEditingController();
    final TextEditingController preparationController = TextEditingController();

    showDialog(
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
                  // Agregar la nueva receta a la lista
                  Recipe newRecipe = Recipe(
                    nameController.text,
                    ingredientsController.text,
                    preparationController.text,
                  );
                  savedRecipes.add(newRecipe); // Cambia recipes a savedRecipes
                  favoriteStatus.add(false); // Agregar estado de favorito
                  expandedStatus.add(false); // Agregar estado de expansión
                  filteredRecipes = savedRecipes; // Resetea la lista filtrada
                });
                Navigator.of(context).pop();
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
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
                starIndex < averageRating.floor()
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

import 'package:flutter/material.dart';

class Recipe {
  final String name; // Nombre de la receta
  final String ingredients; // Ingredientes de la receta
  final String preparation; // Instrucciones de preparación
  List<double> ratings; // Lista de calificaciones

  // Constructor que inicializa el nombre, ingredientes y preparación
  Recipe(this.name, this.ingredients, this.preparation) : ratings = [];
}

// Página que muestra la lista de recetas
class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  // Lista de recetas
  List<Recipe> recipes = [
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
    Recipe(
      'Café Frappé',
      '• Café frío\n• Azúcar\n• Hielo\n• Leche',
      '1. Mezclar café frío, azúcar, y hielo en una licuadora.\n2. Servir con leche.',
    ),
    Recipe(
      'Café con Leche',
      '• Café\n• Leche\n• Azúcar (opcional)',
      '1. Preparar café.\n2. Mezclar con leche caliente.\n3. Agregar azúcar si se desea.',
    ),
    Recipe(
      'Café Irlandés',
      '• Café caliente\n• Whisky\n• Azúcar\n• Crema',
      '1. Preparar café caliente.\n2. Mezclar con whisky y azúcar.\n3. Cubrir con crema.',
    ),
  ];

  List<bool> favoriteStatus = []; // Estado de favorito para cada receta
  List<bool> expandedStatus = []; // Estado expandido para cada receta
  List<Recipe> filteredRecipes = []; // Para almacenar las recetas filtradas
  final TextEditingController searchController =
      TextEditingController(); // Controlador para el campo de búsqueda

  @override
  void initState() {
    super.initState();
    // Inicializar el estado de favoritos y expandido
    favoriteStatus = List.generate(recipes.length, (_) => false);
    expandedStatus = List.generate(recipes.length, (_) => false);
    filteredRecipes =
        recipes; // Inicialmente, todas las recetas están filtradas
    searchController.addListener(
        _filterRecipes); // Escuchar cambios en el campo de búsqueda
  }

  // Método para filtrar recetas según la consulta de búsqueda
  void _filterRecipes() {
    String query =
        searchController.text.toLowerCase(); // Obtener texto en minúsculas
    setState(() {
      // Filtrar las recetas que contienen la consulta
      filteredRecipes = recipes.where((recipe) {
        return recipe.name.toLowerCase().contains(query);
      }).toList();
    });
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
            // Buscador de recetas
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar recetas',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search), // Icono de búsqueda
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount:
                    filteredRecipes.length + 1, // Total de recetas filtradas
                itemBuilder: (context, index) {
                  if (index == filteredRecipes.length) {
                    return const SizedBox(
                        height: 80); // Espacio al final de la lista
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0), // Margen de las tarjetas
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
                                      filteredRecipes[index]
                                          .name, // Nombre de la receta
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                              // Botón para agregar a favoritos
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
                                    favoriteStatus[index] = !favoriteStatus[
                                        index]; // Cambia el estado de favorito
                                  });
                                },
                              ),
                              // Botón para compartir receta
                              IconButton(
                                icon: const Icon(
                                  Icons.share,
                                  size: 24,
                                ),
                                onPressed: () {
                                  // Muestra un mensaje al compartir
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Compartiendo receta'),
                                    ),
                                  );
                                },
                              ),
                              // Botón para expandir/colapsar detalles de la receta
                              IconButton(
                                icon: Icon(
                                  expandedStatus[index]
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  size: 24,
                                ),
                                onPressed: () {
                                  setState(() {
                                    expandedStatus[index] = !expandedStatus[
                                        index]; // Cambia el estado expandido
                                  });
                                },
                              ),
                            ],
                          ),
                          // Mostrar detalles si la receta está expandida
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
                                Text(filteredRecipes[index]
                                    .ingredients), // Ingredientes de la receta
                                const SizedBox(height: 8),
                                const Text(
                                  'Preparación:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(filteredRecipes[index]
                                    .preparation), // Preparación de la receta
                                const SizedBox(height: 16),
                                const Text(
                                  'Productos Recomendados',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildProductCard(), // Tarjeta de producto recomendada
                                    _buildProductCard(), // Otra tarjeta de producto recomendada
                                  ],
                                ),
                                const SizedBox(height: 16),

                                _buildRatingSection(
                                    index), // Sección de calificaciones
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

  // Método para construir la sección de calificaciones
  Widget _buildRatingSection(int index) {
    double averageRating = recipes[index].ratings.isNotEmpty
        ? recipes[index].ratings.reduce((a, b) => a + b) /
            recipes[index].ratings.length // Calcular promedio
        : 0.0; // Promedio por defecto
    int ratingCount = recipes[index].ratings.length; // Contar calificaciones

    return Column(
      children: [
        Text(
          'Promedio: ${averageRating.toStringAsFixed(1)} ($ratingCount calificaciones)', // Mostrar promedio y número de calificaciones
          style: const TextStyle(fontSize: 14),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (starIndex) {
            // Crear estrellas para calificación
            return IconButton(
              icon: Icon(
                starIndex < averageRating.floor()
                    ? Icons.star // Estrella llena si está calificado
                    : Icons.star_border, // Estrella vacía si no está calificado
                color: Colors.amber,
              ),
              onPressed: () {
                setState(() {
                  recipes[index]
                      .ratings
                      .add((starIndex + 1).toDouble()); // Agregar calificación
                });
              },
            );
          }),
        ),
      ],
    );
  }

  // Método para construir una tarjeta de producto recomendada
  Widget _buildProductCard() {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.coffee_maker_outlined,
            size: 40,
            color: Colors.brown[500],
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 174, 97, 71),
              foregroundColor: Colors.white,
            ),
            child: const Text('Comprar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose(); // Limpiar controlador al eliminar la página
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:espresso_dreams/models/recipe_class.dart';
import 'package:espresso_dreams/utils/database_helper.dart';
import 'package:path/path.dart';
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
    _insertInitialRecipes().then((_) {
      _loadRecipes(); // Cargar recetas después de insertar las iniciales
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

  Future<void> _insertInitialRecipes() async {
    // Crear recetas iniciales
    List<Recipe> initialRecipes = [
      Recipe.createNewRecipe(
        'Café Americano',
        'Agua caliente, café molido',
        'Preparar café filtrado y añadir agua caliente.',
        image: 'assets/images/americano-1024x682.jpg', // Ruta de la imagen
      ),
      Recipe.createNewRecipe(
        'Cappuccino',
        'Café expreso, leche vaporizada, espuma de leche',
        'Mezclar café expreso con leche vaporizada y añadir espuma por encima.',
        image: 'assets/images/Cappuccino.jpeg',
      ),
      Recipe.createNewRecipe(
        'Latte',
        'Café expreso, leche vaporizada',
        'Combinar café expreso con leche vaporizada.',
        image: 'assets/images/Latte.jpeg',
      ),
      Recipe.createNewRecipe(
        'Mocha',
        'Café expreso, leche vaporizada, jarabe de chocolate',
        'Mezclar café expreso con leche vaporizada y añadir jarabe de chocolate.',
        image: 'assets/images/Mocha.jpeg',
      ),
    ];

    // Insertar cada receta en la base de datos
    for (var recipe in initialRecipes) {
      bool exists = await DatabaseHelper().recipeExists(recipe.name);
      if (!exists) {
        await DatabaseHelper().insertRecipe(recipe);
      }
    }
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
                                onPressed: () async {
                                  setState(() {
                                    favoriteStatus[index] =
                                        !favoriteStatus[index];
                                    filteredRecipes[index].isFavorite =
                                        favoriteStatus[index];
                                  });

                                  // Actualiza el estado en la base de datos
                                  await DatabaseHelper()
                                      .updateRecipe(filteredRecipes[index]);
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
                                // Mostrar imagen de la receta
                                filteredRecipes[index].image != null
                                    ? Image.asset(filteredRecipes[index].image!)
                                    : const SizedBox
                                        .shrink(), // Si no hay imagen, mostrar nada
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
                                _buildRating(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await deleteLocalDatabase(); // Llama a la función para eliminar la base de datos
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.delete), // Color del botón flotante
      ),
    );
  }

  Future<void> deleteLocalDatabase() async {
    // Obtén el path de la base de datos
    String path = join(await getDatabasesPath(), 'recipes.db');

    // Verifica si la base de datos está abierta y cierra si es necesario
    Database db = await openDatabase(path);

    // Cierra la base de datos
    await db.close();

    // Ahora elimina la base de datos
    await deleteDatabase(path);

    // Opcional: vuelve a cargar las recetas si lo deseas
    await _loadRecipes(); // Asegúrate de que esto esté bien manejado
  }

  // Método para construir la sección de calificaciones
  Widget _buildRating(int index) {
    double averageRating = recipes[index].getAverageRating();
    int ratingCount = recipes[index].getRatingCount();

    return Column(
      children: [
        Text(
          'Promedio: ${averageRating.toStringAsFixed(1)} ($ratingCount calificaciones)',
          style: const TextStyle(fontSize: 14),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (starIndex) {
            // Crear estrellas para calificación
            return IconButton(
              icon: Icon(
                starIndex < averageRating.floor()
                    ? Icons.star
                    : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () {
                setState(() {
                  recipes[index].addRating((starIndex + 1).toDouble());
                  DatabaseHelper().updateRecipe(recipes[
                      index]); // Actualizar la receta en la base de datos
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

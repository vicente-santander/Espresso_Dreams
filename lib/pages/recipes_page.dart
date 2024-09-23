import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'user_page.dart';

class Recipe {
  final String name;
  final String ingredients;
  final String preparation;

  Recipe(this.name, this.ingredients, this.preparation);
}

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
    ),
    Recipe(
      'Café Latte',
      '• Café expreso\n• Leche caliente\n• Espuma de leche',
      '1. Preparar café expreso.\n2. Agregar leche caliente.\n3. Cubrir con espuma de leche.',
    ),
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

  List<bool> favoriteStatus = [];
  List<bool> expandedStatus = [];

  @override
  void initState() {
    super.initState();
    favoriteStatus = List.generate(recipes.length, (_) => false);
    expandedStatus = List.generate(recipes.length, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recetas de Café'),
        backgroundColor: const Color.fromARGB(255, 174, 97, 71),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const UserPage()));
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(
                    'assets/icons/9041988_user_male_icon.svg',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: recipes.length + 1,
          itemBuilder: (context, index) {
            if (index == recipes.length) {
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
                                recipes[index].name,
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
                            color: favoriteStatus[index] ? Colors.red : null,
                            size: 24,
                          ),
                          onPressed: () {
                            setState(() {
                              favoriteStatus[index] = !favoriteStatus[index];
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
                              expandedStatus[index] = !expandedStatus[index];
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
                          Text(recipes[index].ingredients),
                          const SizedBox(height: 8),
                          const Text(
                            'Preparación:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(recipes[index].preparation),
                          const SizedBox(height: 16),
                          Text(recipes[index].preparation),
                          const SizedBox(height: 16),
                          const Text(
                            'Productos Recomendados',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildProductCard(),
                              _buildProductCard(),
                            ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecipeDialog(),
        backgroundColor: const Color.fromARGB(255, 174, 97, 71),
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
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration:
                      const InputDecoration(labelText: 'Nombre de la receta'),
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
                  recipes.add(Recipe(
                    nameController.text,
                    ingredientsController.text,
                    preparationController.text,
                  ));
                  favoriteStatus.add(false);
                  expandedStatus.add(false);
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

  Widget _buildProductCard() {
    return Card(
      child: Column(
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
}

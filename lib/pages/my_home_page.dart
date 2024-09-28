import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:espresso_dreams/pages/user_page.dart';
import 'package:espresso_dreams/pages/recipes_page.dart';
import 'package:espresso_dreams/pages/product_page.dart';
import 'package:espresso_dreams/pages/forum_page.dart';
import 'package:espresso_dreams/pages/saved_recipes_page.dart';
import 'package:espresso_dreams/pages/my_recipes_page.dart';
import 'package:espresso_dreams/pages/sell_product_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isFavorite = false; // Variable para controlar el estado del favorito

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
              color: Colors.yellow[200],
              child: const DrawerHeader(
                child: Text(
                  'Espresso Dreams',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            ListTile(
              leading: SvgPicture.asset(
                'assets/icons/9041988_user_male_icon.svg',
                width: 24,
                height: 24,
              ),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Recetas'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecipesPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.favorite), // Icono para Recetas guardadas
              title: const Text('Recetas favoritas'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SavedRecipesPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long), // Icono para Mis recetas
              title: const Text('Mis recetas'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyRecipesPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Comprar'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.sell),
              title: const Text('Vender productos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SellProductsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.forum),
              title: const Text('Foro'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ForumPage(),
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
            // Card para la receta más vista
            Card(
              margin: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'La receta más vista',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Café Irlandés',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      '• Café caliente\n• Whisky\n• Azúcar\n• Crema',
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Instrucciones:\n1. Preparar café caliente.\n2. Mezclar con whisky y azúcar.\n3. Cubrir con crema.',
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : null,
                          ),
                          onPressed: () {
                            setState(() {
                              isFavorite = !isFavorite;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Card para el producto más vendido
            Card(
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/icons/cafetera.jpeg',
                          width: 100,
                          height: 100,
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Producto más vendido',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Cafetera',
                                style: TextStyle(fontSize: 18),
                              ),
                              SizedBox(height: 5),
                              Text('Cantidad disponible: 10'),
                              SizedBox(height: 5),
                              Text('Costo: \$150.00'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Comprar'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

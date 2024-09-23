import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:espresso_dreams/pages/user_page.dart';
import 'package:espresso_dreams/pages/recipes_page.dart';
import 'package:espresso_dreams/pages/product_page.dart';
import 'package:espresso_dreams/pages/forum_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const UserPage()));
              },
              child: Container(
                width: 50, // Ajusta el tamaño del botón
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.white, // Color de fondo del botón
                  shape: BoxShape.circle, // Hace que el botón sea redondo
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RecipesPage()));
                  },
                  child: const Text('Recetas'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProductsPage()));
                  },
                  child: const Text('Comprar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ForumPage()));
                  },
                  child: const Text('Foro'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

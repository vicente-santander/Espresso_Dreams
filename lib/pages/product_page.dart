import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Product {
  final String name;
  final String description;
  final double price;

  Product(this.name, this.description, this.price);
}

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final Map<Product, int> cart = {}; // Para almacenar productos y cantidades
  final List<int> quantities = List.filled(5, 0); // Inicializa cantidades en 0

  void addToCart(Product product, int quantity) {
    setState(() {
      if (cart.containsKey(product)) {
        cart[product] = cart[product]! + quantity; // Incrementar cantidad
      } else {
        cart[product] = quantity; // Añadir nuevo producto
      }
    });
  }

  void showPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        double totalPrice = cart.entries
            .map((entry) => entry.key.price * entry.value)
            .reduce((a, b) => a + b);

        return AlertDialog(
          title: const Text('Resumen de Compra'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              children: [
                ...cart.entries.map((entry) {
                  final product = entry.key;
                  final quantity = entry.value;
                  return ListTile(
                    title: Text('${product.name} x$quantity'),
                    trailing: Text(
                        '\$${(product.price * quantity).toStringAsFixed(3)}'),
                  );
                }),
                const Divider(),
                Text(
                  'Total a Pagar: \$${totalPrice.toStringAsFixed(3)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar dialog
              },
              child: const Text('Seguir comprando'),
            ),
            TextButton(
              onPressed: () {
                // Aquí puedes implementar la lógica de pago
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Proceso de pago iniciado')),
                );
                Navigator.of(context).pop(); // Cerrar dialog
              },
              child: const Text('Pagar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Product> products = [
      Product('Café Orgánico', 'Café de origen 100% orgánico', 15.000),
      Product('Molinillo de Café', 'Molinillo manual para café', 25.500),
      Product('Taza de Café', 'Taza de cerámica para café', 8.000),
      Product('Café Espresso', 'Café en grano de espresso', 12.750),
      Product('Cafetera Francesa', 'Cafetera para preparar café', 20.000),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos de Café'),
        backgroundColor: const Color.fromARGB(255, 174, 97, 71),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  products[index].name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(products[index].description),
                                Text(
                                    '\$${products[index].price.toStringAsFixed(3)}'),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  if (quantities[index] > 0) {
                                    setState(() {
                                      quantities[index]--;
                                    });
                                  }
                                },
                              ),
                              Text(quantities[index].toString(),
                                  style: const TextStyle(fontSize: 18)),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    quantities[index]++;
                                  });
                                },
                              ),
                              TextButton(
                                onPressed: () {
                                  if (quantities[index] > 0) {
                                    addToCart(
                                        products[index], quantities[index]);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Selecciona una cantidad mayor a 0')),
                                    );
                                  }
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 174, 97, 71),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Comprar'),
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
            if (cart.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      'Total a pagar: \$${cart.entries.map((entry) => entry.key.price * entry.value).reduce((a, b) => a + b).toStringAsFixed(3)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: showPaymentDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 174, 97, 71),
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        foregroundColor: Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/shopping_cart_icon.svg', // Cambia esto a la ruta de tu ícono SVG
                            height: 24,
                            width: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Pagar (${cart.length} productos)',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

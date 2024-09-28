import 'package:flutter/material.dart';

class Product {
  String name;
  String description;
  int price;
  int quantity;

  Product(this.name, this.description, this.price, this.quantity);
}

class SellProductsPage extends StatefulWidget {
  const SellProductsPage({super.key});

  @override
  State<SellProductsPage> createState() => _SellProductsPageState();
}

class _SellProductsPageState extends State<SellProductsPage> {
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    _loadExampleProducts(); // Cargar productos de ejemplo al iniciar
  }

  void _loadExampleProducts() {
    products.add(Product("Prensa francesa", "Exportada de Francia", 1500, 10));
    products.add(Product("Cafe premium", "Café fuerte y concentrado", 2000, 5));
    products.add(
        Product("Leche de coco", "Leche de coco de origen vegetal", 2500, 8));
    products.add(Product("Espumadora", "Espumadora de leche sin uso", 3000, 6));
    products
        .add(Product("Taza", "Taza con diseño de Legue of Legends", 2800, 4));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vender Productos'),
        backgroundColor: const Color.fromARGB(255, 174, 97, 71),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(child: _buildProductList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _sellProduct(),
        backgroundColor: const Color.fromARGB(255, 174, 97, 71),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: Icon(
              Icons.shopping_cart,
              color: Colors.brown[500],
              size: 40,
            ),
            title: Text(products[index].name),
            subtitle: Text(
                '${products[index].description} (Cantidad: ${products[index].quantity})'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('\$${products[index].price}'),
                IconButton(
                  icon: const Icon(Icons.edit),
                  color: Colors.brown,
                  onPressed: () {
                    _showEditProductDialog(index);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _sellProduct() {
    final TextEditingController productNameController = TextEditingController();
    final TextEditingController productDescriptionController =
        TextEditingController();
    final TextEditingController productPriceController =
        TextEditingController();
    final TextEditingController productQuantityController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Producto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: productNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Producto',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: productDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción del Producto',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: productPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Precio del Producto',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: productQuantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad disponible',
                    border: OutlineInputBorder(),
                  ),
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
                _addProduct(
                  productNameController.text,
                  productDescriptionController.text,
                  productPriceController.text,
                  productQuantityController.text,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  void _showEditProductDialog(int index) {
    final TextEditingController productNameController =
        TextEditingController(text: products[index].name);
    final TextEditingController productDescriptionController =
        TextEditingController(text: products[index].description);
    final TextEditingController productPriceController =
        TextEditingController(text: products[index].price.toString());
    final TextEditingController productQuantityController =
        TextEditingController(text: products[index].quantity.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Producto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: productNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Producto',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: productDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción del Producto',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: productPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Precio del Producto',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: productQuantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad disponible',
                    border: OutlineInputBorder(),
                  ),
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
                _editProduct(
                  index,
                  productNameController.text,
                  productDescriptionController.text,
                  productPriceController.text,
                  productQuantityController.text,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _addProduct(
      String name, String description, String priceText, String quantityText) {
    if (name.isEmpty ||
        description.isEmpty ||
        priceText.isEmpty ||
        quantityText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor complete todos los campos'),
        ),
      );
      return;
    }

    int? price = int.tryParse(priceText);
    int? quantity = int.tryParse(quantityText);
    if (price == null || quantity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('El precio y la cantidad deben ser números enteros válidos'),
        ),
      );
      return;
    }

    setState(() {
      products.add(Product(name, description, price, quantity));
    });
  }

  void _editProduct(int index, String name, String description,
      String priceText, String quantityText) {
    if (name.isEmpty ||
        description.isEmpty ||
        priceText.isEmpty ||
        quantityText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor complete todos los campos'),
        ),
      );
      return;
    }

    int? price = int.tryParse(priceText);
    int? quantity = int.tryParse(quantityText);
    if (price == null || quantity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('El precio y la cantidad deben ser números enteros válidos'),
        ),
      );
      return;
    }

    setState(() {
      products[index].name = name;
      products[index].description = description;
      products[index].price = price;
      products[index].quantity = quantity;
    });
  }
}

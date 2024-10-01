class Product {
  String name;
  String description;
  int price;
  int availableQuantity;

  Product(this.name, this.description, this.price, this.availableQuantity);

  static Product? addProduct(
      String name, String description, String priceText, String quantityText) {
    if (name.isEmpty ||
        description.isEmpty ||
        priceText.isEmpty ||
        quantityText.isEmpty) {
      return null; // Retornar null si los campos están vacíos
    }

    int? price = int.tryParse(priceText);
    int? quantity = int.tryParse(quantityText);
    if (price == null || quantity == null) {
      return null; // Retornar null si el precio o la cantidad no son válidos
    }

    return Product(
        name, description, price, quantity); // Retornar el nuevo producto
  }

  // Método para editar los atributos del producto
  void edit(
      String newName, String newDescription, int newPrice, int newQuantity) {
    name = newName;
    description = newDescription;
    price = newPrice;
    availableQuantity = newQuantity;
  }

  // Método para calcular el total a pagar
  static int calculateTotal(Map<Product, int> cart) {
    return cart.entries
        .map((entry) => entry.key.price * entry.value)
        .reduce((a, b) => a + b);
  }
}

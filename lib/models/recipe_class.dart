class Recipe {
  int? id; // Agregar un campo id para la base de datos
  String name;
  String ingredients;
  String preparation;
  String? image;
  List<double> ratings;
  bool isfavorite;

  Recipe(this.name, this.ingredients, this.preparation, {this.image})
      : ratings = [],
        isfavorite = false;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ingredients': ingredients,
      'preparation': preparation,
      'image': image,
    };
  }

  // Método para crear una receta desde un mapa
  Recipe.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        ingredients = map['ingredients'],
        preparation = map['preparation'],
        image = map['image'],
        ratings = [],
        isfavorite = false;

  // Método para actualizar la receta
  void updateRecipe({
    required String newName,
    required String newIngredients,
    required String newPreparation,
  }) {
    name = newName;
    ingredients = newIngredients;
    preparation = newPreparation;
  }

  double getAverageRating() {
    if (ratings.isEmpty) return 0.0;
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }

  int getRatingCount() {
    return ratings.length;
  }

  void addRating(double rating) {
    ratings.add(rating);
  }

  // Método para crear una nueva receta
  static Recipe createNewRecipe(
      String name, String ingredients, String preparation) {
    return Recipe(name, ingredients, preparation);
  }
}

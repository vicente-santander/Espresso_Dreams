class Recipe {
  String name;
  String ingredients;
  String preparation;
  List<double> ratings;

  Recipe(this.name, this.ingredients, this.preparation) : ratings = [];

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

class Recipe {
  int? id;
  String name;
  String ingredients;
  String preparation;
  String? image;
  List<double> ratings = [];
  bool isFavorite;
  bool isMine; // Este campo se guardará en la base de datos

  Recipe(
    this.name,
    this.ingredients,
    this.preparation, {
    this.image,
    this.isFavorite = false,
    this.isMine = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ingredients': ingredients,
      'preparation': preparation,
      'image': image,
      'isFavorite': isFavorite ? 1 : 0,
      'isMine': isMine ? 1 : 0,
    };
  }

  static Recipe fromMap(Map<String, dynamic> map) {
    return Recipe(
      map['name'],
      map['ingredients'],
      map['preparation'],
      image: map['image'],
      isFavorite: map['isFavorite'] == 1,
      isMine: map['isMine'] == 1,
    )..id = map['id'];
  }

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
  // Método para crear una nueva receta
  static Recipe createNewRecipe(
      String name, String ingredients, String preparation,
      {String? image}) {
    return Recipe(name, ingredients, preparation, image: image);
  }
}

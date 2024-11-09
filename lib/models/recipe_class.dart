class Recipe {
  int? id;
  String name;
  String ingredients;
  String preparation;
  String? image;
  List<double> ratings = [];
  bool isFavorite;
  bool isMine;
  String dateCreated; // Fecha de registro
  int preparationTime; // Tiempo de preparación en minutos
  String associatedProducts; // Productos asociados

  Recipe(
    this.name,
    this.ingredients,
    this.preparation, {
    this.image,
    this.isFavorite = false,
    this.isMine = false,
    required this.dateCreated,
    required this.preparationTime,
    required this.associatedProducts,
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
      'dateCreated': dateCreated,
      'preparationTime': preparationTime,
      'associatedProducts': associatedProducts
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
      dateCreated: map['dateCreated'],
      preparationTime: map['preparationTime'],
      associatedProducts: map['associatedProducts'],
    )..id = map['id'];
  }

  // Método para actualizar la receta
  void updateRecipe({
    required String newName,
    required String newIngredients,
    required String newPreparation,
    required int newPreparationTime,
    required String newAssociatedProducts,
  }) {
    name = newName;
    ingredients = newIngredients;
    preparation = newPreparation;
    preparationTime = newPreparationTime;
    associatedProducts = newAssociatedProducts;
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

  static Recipe createNewRecipe(
    String name,
    String ingredients,
    String preparation,
    String dateCreated,
    int preparationTime,
    String associatedProducts,
    String? path, // Aquí se usará el path directamente
  ) {
    return Recipe(
      name,
      ingredients,
      preparation,
      image: path, // Asignación del path al campo image
      dateCreated: dateCreated,
      preparationTime: preparationTime,
      associatedProducts: associatedProducts,
    );
  }
}

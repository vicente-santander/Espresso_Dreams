import 'dart:convert'; // Importar para convertir JSON a objeto
import 'package:flutter/services.dart'; // Para cargar el archivo JSON
import 'package:espresso_dreams/utils/database_helper.dart';

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
  int usageCount;

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
    this.usageCount = 0,
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
      'associatedProducts': associatedProducts,
      'usageCount': usageCount,
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
      usageCount: map['usageCount'] ?? 0,
    )..id = map['id'];
  }

  static Future<void> loadInitialRecipes(DatabaseHelper dbHelper) async {
    // Cargar el archivo JSON
    final String response =
        await rootBundle.loadString('assets/data/barista.json');
    final List<dynamic> data = json.decode(response);

    // Convertir los datos del JSON en objetos Recipe
    List<Recipe> recipes = data.map((recipeData) {
      return Recipe(
        recipeData['name'],
        recipeData['ingredients'],
        recipeData['preparation'],
        image: recipeData['image'],
        isFavorite: recipeData['isFavorite'],
        isMine: recipeData['isMine'],
        dateCreated: recipeData['dateCreated'],
        preparationTime: recipeData['preparationTime'],
        associatedProducts: recipeData['associatedProducts'],
      );
    }).toList();

    // Insertar las recetas en la base de datos
    for (var recipe in recipes) {
      bool exists = await DatabaseHelper().recipeExists(recipe.name);
      if (!exists) {
        await DatabaseHelper().insertRecipe(recipe);
      }
    }
  }

  void incrementUsageCount() {
    usageCount += 1; // Aumenta el contador de uso
    DatabaseHelper().updateRecipe(this); // Actualiza en la base de datos
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
    isMine = true;
  }

  // Método para actualizar la receta
  void updateRecipeImage({
    required String newName,
    required String newIngredients,
    required String newPreparation,
    required int newPreparationTime,
    required String newAssociatedProducts,
    required String? newPath,
  }) {
    name = newName;
    ingredients = newIngredients;
    preparation = newPreparation;
    preparationTime = newPreparationTime;
    associatedProducts = newAssociatedProducts;
    image = newPath;
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

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:espresso_dreams/models/recipe_class.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'recipes.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE recipes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          ingredients TEXT,
          preparation TEXT,
          image TEXT,
          isFavorite INTEGER DEFAULT 0,
          isMine INTEGER DEFAULT 0, 
          dateCreated TEXT,
          preparationTime INTEGER,
          associatedProducts TEXT
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Agregar las nuevas columnas si se actualiza la versión de la base de datos
          await db.execute('''
          ALTER TABLE recipes ADD COLUMN dateCreated TEXT;
          ALTER TABLE recipes ADD COLUMN preparationTime INTEGER;
          ALTER TABLE recipes ADD COLUMN associatedProducts TEXT;
          ''');
        }
      },
    );
  }

  Future<void> insertRecipe(Recipe recipe) async {
    final db = await database;
    await db.insert(
      'recipes',
      recipe.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Recipe>> getRecipes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('recipes');

    return List.generate(maps.length, (i) {
      return Recipe.fromMap(maps[i]);
    });
  }

  Future<void> updateRecipe(Recipe recipe) async {
    final db = await database;
    await db.update(
      'recipes',
      recipe.toMap(),
      where: 'id = ?',
      whereArgs: [recipe.id],
    );
  }

  Future<void> deleteRecipe(int id) async {
    final db = await database;
    await db.delete(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> recipeExists(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recipes',
      where: 'name = ?',
      whereArgs: [name],
    );

    return maps.isNotEmpty; // Devuelve true si ya existe
  }

  Future<List<Recipe>> getFavoriteRecipes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recipes',
      where: 'isFavorite = ?',
      whereArgs: [1],
    );

    return List.generate(maps.length, (i) {
      return Recipe.fromMap(maps[i]);
    });
  }

  Future<Recipe> getLastRecipe() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recipes',
      orderBy: 'dateCreated DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Recipe.fromMap(maps.first);
    } else {
      // Si no hay recetas, devuelve la receta predeterminada
      return Recipe.createNewRecipe(
        'Mocha',
        'Café expreso, leche vaporizada, jarabe de chocolate',
        'Mezclar café expreso con leche vaporizada y añadir jarabe de chocolate.',
        '2024-11-01',
        7,
        'Vaporizador de leche',
        'assets/images/Mocha.jpeg',
      );
    }
  }
}

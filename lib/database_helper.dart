import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Singleton class to manage the database
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  // Getter for the database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'memories.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Create the images table
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE images (
        id TEXT PRIMARY KEY,
        is_memory INTEGER,
        swipe_date TEXT
      )
    ''');
  }

  // Insert a swiped image into the database
  Future<void> insertSwipedImage(String id, int isMemory, String swipeDate) async {
    final db = await database;
    await db.insert(
      'images',
      {
        'id': id,
        'is_memory': isMemory,
        'swipe_date': swipeDate,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve all swiped image IDs
  Future<Set<String>> getSwipedIds() async {
    final db = await database;
    final result = await db.query('images', columns: ['id']);
    return result.map((row) => row['id'] as String).toSet();
  }

  // Retrieve memories (images swiped right)
  Future<List<Map<String, dynamic>>> getMemories() async {
    final db = await database;
    return await db.query('images', where: 'is_memory = 1');
  }
}
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/nutrition_entry.dart';

class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();
  factory LocalStorage() => _instance;
  LocalStorage._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'nutrition.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE entries(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            foodName TEXT,
            calories INTEGER,
            protein REAL,
            carbs REAL,
            fat REAL,
            timestamp TEXT
          )
        ''');
      },
    );
  }

  Future<void> saveEntry(NutritionEntry entry) async {
    final db = await database;
    await db.insert('entries', entry.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<NutritionEntry>> loadEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('entries', orderBy: 'timestamp DESC');
    return List.generate(maps.length, (i) => NutritionEntry.fromMap(maps[i]));
  }

  Future<void> deleteEntry(DateTime timestamp) async {
    final db = await database;
    await db.delete('entries', where: 'timestamp = ?', whereArgs: [timestamp.toIso8601String()]);
  }

  Future<void> updateEntry(NutritionEntry entry) async {
    final db = await database;
    await db.update(
      'entries',
      entry.toMap(),
      where: 'timestamp = ?',
      whereArgs: [entry.timestamp.toIso8601String()],
    );
  }
} 
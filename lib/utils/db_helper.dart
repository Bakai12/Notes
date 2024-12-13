import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:notes/models/note.dart';

class DBHelper {
  static const String _databaseName = 'notes.db';
  static const int _databaseVersion = 1;
  static const String tableName = 'notes';

  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<int> insert(Note note) async {
    final db = await database;
    return await db.insert(tableName, note.toMap());
  }

  Future<int> update(Note note) async {
    final db = await database;
    return await db.update(
      tableName,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<List<Note>> fetchNotes() async {
    final db = await database;
    final maps = await db.query(tableName, orderBy: 'date DESC');
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  Future<int> deleteNoteById(int id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

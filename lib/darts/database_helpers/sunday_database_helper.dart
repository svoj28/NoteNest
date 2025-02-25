import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // New database name
  final String _dbName = 'note_nest4.db';

  // Database getter
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Delete the existing database and create a new one
  Future<void> resetDatabase() async {
    final dbPath = join(await getDatabasesPath(), _dbName);
    await deleteDatabase(dbPath);
    _database = await _initDatabase();
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    final dbPath = join(await getDatabasesPath(), _dbName);
    // Debug: Print database path
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE sunday(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, content TEXT, date_created TEXT, image_path TEXT, audio_path TEXT, pin INTEGER DEFAULT 0)',
        );
        await db.execute(
          'CREATE TABLE lecture(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, content TEXT, date_created TEXT, image_path TEXT, audio_path TEXT, pin INTEGER DEFAULT 0)',
        );
        await db.execute(
          'CREATE TABLE personal(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, content TEXT, date_created TEXT, image_path TEXT, audio_path TEXT, pin INTEGER DEFAULT 0)',
        );
        await db.execute(
          'CREATE TABLE devotion(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, content TEXT, date_created TEXT, image_path TEXT, audio_path TEXT, pin INTEGER DEFAULT 0)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 1) {
          // Handle schema upgrades if needed
        }
      },
    );
  }

  // CRUD operations for Sunday
  Future<void> insertsundayNote(String title, String content,
      String dateCreated, String? imagePath, String? audioPath,
      {bool isPinned = false}) async {
    final db = await database;
    await db.insert(
      'sunday',
      {
        'title': title,
        'content': content,
        'date_created': dateCreated,
        'image_path': imagePath,
        'audio_path': audioPath,
        'pin': isPinned ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getsundayNotes() async {
    final db = await database;
    return await db.query('sunday', orderBy: 'pin DESC, id DESC');
  }

  Future<Map<String, dynamic>?> getsundayNoteById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sunday',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<void> deletesundayNoteById(int id) async {
    final db = await database;
    await db.delete(
      'sunday',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updatesundayNote(Map<String, dynamic> note) async {
    final db = await database;
    await db.update(
      'sunday',
      note,
      where: 'id = ?',
      whereArgs: [note['id']],
    );
  }

  Future<List<Map<String, dynamic>>> searchSundayNotes(String query) async {
    final db = await database;
    return await db.query(
      'sunday',
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
    );
  }

  Future<void> updateSundayNotePinned(int id, bool isPinned) async {
    final db = await database;
    await db.update(
      'sunday',
      {'pin': isPinned ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD operations for Lecture
  Future<void> insertlectureNote(String title, String content,
      String dateCreated, String? imagePath, String? audioPath,
      {bool isPinned = false}) async {
    final db = await database;
    await db.insert(
      'lecture',
      {
        'title': title,
        'content': content,
        'date_created': dateCreated,
        'image_path': imagePath,
        'audio_path': audioPath,
        'pin': isPinned ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getlectureNotes() async {
    final db = await database;
    return await db.query('lecture', orderBy: 'pin DESC, id DESC');
  }

  Future<Map<String, dynamic>?> getlectureNoteById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'lecture',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<void> deletelectureNoteById(int id) async {
    final db = await database;
    await db.delete(
      'lecture',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updatelectureNote(Map<String, dynamic> note) async {
    final db = await database;
    await db.update(
      'lecture',
      note,
      where: 'id = ?',
      whereArgs: [note['id']],
    );
  }

  Future<List<Map<String, dynamic>>> searchLectureNotes(String query) async {
    final db = await database;
    return await db.query(
      'lecture',
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
    );
  }

  Future<void> updateLectureNotePinned(int id, bool isPinned) async {
    final db = await database;
    await db.update(
      'sunday',
      {'pin': isPinned ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD operations for Personal
  Future<void> insertpersonalNote(String title, String content,
      String dateCreated, String? imagePath, String? audioPath,
      {bool isPinned = false}) async {
    final db = await database;
    await db.insert(
      'personal',
      {
        'title': title,
        'content': content,
        'date_created': dateCreated,
        'image_path': imagePath,
        'audio_path': audioPath,
        'pin': isPinned ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getpersonalNotes() async {
    final db = await database;
    return await db.query('personal', orderBy: 'pin DESC, id DESC');
  }

  Future<Map<String, dynamic>?> getpersonalNoteById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'personal',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<void> deletepersonalNoteById(int id) async {
    final db = await database;
    await db.delete(
      'personal',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updatepersonalNote(Map<String, dynamic> note) async {
    final db = await database;
    await db.update(
      'personal',
      note,
      where: 'id = ?',
      whereArgs: [note['id']],
    );
  }

  Future<List<Map<String, dynamic>>> searchPersonalNotes(String query) async {
    final db = await database;
    return await db.query(
      'personal',
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
    );
  }

  Future<void> updatePersonalNotePinned(int id, bool isPinned) async {
    final db = await database;
    await db.update(
      'sunday',
      {'pin': isPinned ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD operations for Devotion
  Future<void> insertdevotionNote(String title, String content,
      String dateCreated, String? imagePath, String? audioPath,
      {bool isPinned = false}) async {
    final db = await database;
    await db.insert(
      'devotion',
      {
        'title': title,
        'content': content,
        'date_created': dateCreated,
        'image_path': imagePath,
        'audio_path': audioPath,
        'pin': isPinned ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getdevotionNotes() async {
    final db = await database;
    return await db.query('devotion', orderBy: 'pin DESC, id DESC');
  }

  Future<Map<String, dynamic>?> getdevotionNoteById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'devotion',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<void> deletedevotionNoteById(int id) async {
    final db = await database;
    await db.delete(
      'devotion',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updatedevotionNote(Map<String, dynamic> note) async {
    final db = await database;
    await db.update(
      'devotion',
      note,
      where: 'id = ?',
      whereArgs: [note['id']],
    );
  }

  Future<List<Map<String, dynamic>>> searchDevotionNotes(String query) async {
    final db = await database;
    return await db.query(
      'devotion',
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
    );
  }

  Future<void> updateDevotionNotePinned(int id, bool isPinned) async {
    final db = await database;
    await db.update(
      'sunday',
      {'pin': isPinned ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

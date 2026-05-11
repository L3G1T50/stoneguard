import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  static const _dbName = 'stoneguard.db';
  static const _keyName = 'stoneguard_db_key';
  static const _secureStorage = FlutterSecureStorage();

  Future<String> _getOrCreateKey() async {
    final existing = await _secureStorage.read(key: _keyName);
    if (existing != null && existing.isNotEmpty) return existing;

    // 32-byte random key as hex string
    final bytes = List<int>.generate(32, (i) => DateTime.now().millisecondsSinceEpoch % 256);
    final key = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    await _secureStorage.write(key: _keyName, value: key);
    return key;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(_dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    final key = await _getOrCreateKey();

    return await openDatabase(path,
        password: key, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE journal_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        pain INTEGER NOT NULL,
        note TEXT NOT NULL,
        side TEXT,
        stone_passed INTEGER DEFAULT 0,
        symptoms TEXT
      )
    ''');
  }

  Future<int> insertEntry(Map<String, dynamic> entry) async {
    final db = await instance.database;
    return await db.insert('journal_entries', {
      'date': entry['date'],
      'pain': entry['pain'],
      'note': entry['note'],
      'side': entry['side'] ?? 'None',
      'stone_passed': (entry['stonePassed'] == true) ? 1 : 0,
      'symptoms': (entry['symptoms'] as List).join(','),
    });
  }

  Future<List<Map<String, dynamic>>> getAllEntries() async {
    final db = await instance.database;
    final rows = await db.query('journal_entries', orderBy: 'date DESC');
    return rows.map((row) => {
      'id': row['id'],
      'date': row['date'],
      'pain': row['pain'],
      'note': row['note'],
      'side': row['side'],
      'stonePassed': row['stone_passed'] == 1,
      'symptoms': row['symptoms'].toString().isEmpty
          ? <String>[]
          : row['symptoms'].toString().split(','),
    }).toList();
  }

  Future<int> updateEntry(int id, Map<String, dynamic> entry) async {
    final db = await instance.database;
    return await db.update(
      'journal_entries',
      {
        'pain': entry['pain'],
        'note': entry['note'],
        'side': entry['side'] ?? 'None',
        'stone_passed': (entry['stonePassed'] == true) ? 1 : 0,
        'symptoms': (entry['symptoms'] as List).join(','),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteEntry(int id) async {
    final db = await instance.database;
    return await db.delete('journal_entries', where: 'id = ?', whereArgs: [id]);
  }

  Future closeDB() async {
    final db = await instance.database;
    db.close();
  }
}

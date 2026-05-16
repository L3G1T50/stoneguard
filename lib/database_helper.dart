// ─── DATABASE HELPER ───────────────────────────────────────────────────────────
// Encrypted SQLite database using sqflite_sqlcipher.
// The 32-byte key is stored in FlutterSecureStorage (Android Keystore /
// iOS Keychain) and generated once on first run.
//
// Fix 3b: all debugPrint replaced with AppLogger — release builds silent.
// Fix 4:  _initDB detects key-loss / wrong-key failures, wipes the
//         corrupted DB file + orphaned secure key, then retries once with
//         a freshly generated key so the app never gets stuck in a crash
//         loop.  If the retry also fails the error is rethrown so
//         main.dart’s global handler can show the user a clear dialog.

import 'dart:io';
import 'dart:math';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'app_logger.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  static const _dbName  = 'stoneguard.db';
  static const _keyName = 'stoneguard_db_key';
  static const _secureStorage = FlutterSecureStorage();

  // ── Key management ─────────────────────────────────────────────────────────
  // Generates a cryptographically secure 32-byte hex key on first run
  // and stores it in FlutterSecureStorage.  Subsequent calls return the
  // stored value.  Rethrows on failure so _initDB surfaces the error.
  Future<String> _getOrCreateKey() async {
    try {
      final existing = await _secureStorage.read(key: _keyName);
      if (existing != null && existing.isNotEmpty) return existing;

      final rng   = Random.secure();
      final bytes = List<int>.generate(32, (_) => rng.nextInt(256));
      final key   = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      await _secureStorage.write(key: _keyName, value: key);
      return key;
    } catch (e, st) {
      AppLogger.error('DatabaseHelper', '_getOrCreateKey error', e, st);
      rethrow; // intentional: a missing key must surface, not be swallowed
    }
  }

  // ── Database accessor ───────────────────────────────────────────────────────
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(_dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path   = join(dbPath, filePath);
    final key    = await _getOrCreateKey();

    try {
      return await openDatabase(
        path,
        password: key,
        version: 1,
        onCreate: _createDB,
      );
    } catch (e, st) {
      // ── Fix 4: key-loss / wrong-key recovery ────────────────────────────
      // openDatabase throws when the stored key no longer matches the DB
      // (e.g. app-data clear wiped the keystore but left the DB file, or
      // the OS rotated the keystore).  We:
      //   1. Delete the unreadable DB file from disk.
      //   2. Delete the orphaned secure key so _getOrCreateKey() makes a
      //      fresh one on the next call.
      //   3. Retry openDatabase once — this time it will create a blank DB.
      // If the retry fails too, we rethrow so main.dart’s global error
      // handler can show the user an explicit reset dialog.
      AppLogger.error(
        'DatabaseHelper',
        'openDatabase failed — attempting key-loss recovery',
        e,
        st,
      );
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
        await _secureStorage.delete(key: _keyName);
        final freshKey = await _getOrCreateKey();
        AppLogger.debug('DatabaseHelper', 'Recovery: opening blank DB with new key');
        return await openDatabase(
          path,
          password: freshKey,
          version: 1,
          onCreate: _createDB,
        );
      } catch (retryError, retrySt) {
        AppLogger.error(
          'DatabaseHelper',
          'Recovery retry also failed — rethrowing for global handler',
          retryError,
          retrySt,
        );
        rethrow;
      }
    }
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

  // ── CRUD ─────────────────────────────────────────────────────────────────────

  /// Returns the new row id, or -1 on failure.
  Future<int> insertEntry(Map<String, dynamic> entry) async {
    try {
      final db = await instance.database;
      return await db.insert('journal_entries', {
        'date':         entry['date'],
        'pain':         entry['pain'],
        'note':         entry['note'],
        'side':         entry['side'] ?? 'None',
        'stone_passed': (entry['stonePassed'] == true) ? 1 : 0,
        'symptoms':     (entry['symptoms'] as List).join(','),
      });
    } catch (e, st) {
      AppLogger.error('DatabaseHelper', 'insertEntry failed', e, st);
      return -1;
    }
  }

  /// Returns all journal entries, or [] on failure.
  Future<List<Map<String, dynamic>>> getAllEntries() async {
    try {
      final db   = await instance.database;
      final rows = await db.query('journal_entries', orderBy: 'date DESC');
      return rows.map((row) => {
        'id':          row['id'],
        'date':        row['date'],
        'pain':        row['pain'],
        'note':        row['note'],
        'side':        row['side'],
        'stonePassed': row['stone_passed'] == 1,
        'symptoms':    row['symptoms'].toString().isEmpty
            ? <String>[]
            : row['symptoms'].toString().split(','),
      }).toList();
    } catch (e, st) {
      AppLogger.error('DatabaseHelper', 'getAllEntries failed', e, st);
      return [];
    }
  }

  /// Returns the number of rows updated, or -1 on failure.
  Future<int> updateEntry(int id, Map<String, dynamic> entry) async {
    try {
      final db = await instance.database;
      return await db.update(
        'journal_entries',
        {
          'pain':         entry['pain'],
          'note':         entry['note'],
          'side':         entry['side'] ?? 'None',
          'stone_passed': (entry['stonePassed'] == true) ? 1 : 0,
          'symptoms':     (entry['symptoms'] as List).join(','),
        },
        where:     'id = ?',
        whereArgs: [id],
      );
    } catch (e, st) {
      AppLogger.error('DatabaseHelper', 'updateEntry failed', e, st);
      return -1;
    }
  }

  /// Returns the number of rows deleted, or -1 on failure.
  Future<int> deleteEntry(int id) async {
    try {
      final db = await instance.database;
      return await db.delete(
        'journal_entries',
        where:     'id = ?',
        whereArgs: [id],
      );
    } catch (e, st) {
      AppLogger.error('DatabaseHelper', 'deleteEntry failed', e, st);
      return -1;
    }
  }

  Future<void> closeDB() async {
    try {
      final db = await instance.database;
      await db.close();
    } catch (e, st) {
      AppLogger.error('DatabaseHelper', 'closeDB failed', e, st);
    }
  }
}

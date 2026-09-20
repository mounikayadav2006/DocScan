import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/scanned_document.dart';

/// Singleton wrapper around a local SQLite database.
///
/// This is what makes the app work fully offline: every scanned document
/// (its title, image path, and extracted text) is persisted on-device,
/// with no backend/server required for the MVP.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'docscan.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE documents(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            imagePath TEXT NOT NULL,
            extractedText TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertDocument(ScannedDocument doc) async {
    final db = await database;
    return db.insert('documents', doc.toMap());
  }

  Future<List<ScannedDocument>> getAllDocuments() async {
    final db = await database;
    final maps = await db.query('documents', orderBy: 'createdAt DESC');
    return maps.map((m) => ScannedDocument.fromMap(m)).toList();
  }

  Future<int> deleteDocument(int id) async {
    final db = await database;
    return db.delete('documents', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateDocument(ScannedDocument doc) async {
    final db = await database;
    return db.update(
      'documents',
      doc.toMap(),
      where: 'id = ?',
      whereArgs: [doc.id],
    );
  }
}

import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static Database? _db;

  static Future<Database> getInstance() async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'dnd_notes_companion.db');

    _db = await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        // campaigns
        await db.execute('''
          CREATE TABLE campaigns (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            edition TEXT,
            icon_codepoint INTEGER,
            created_at INTEGER NOT NULL
          )
        ''');

        // categories
        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            campaign_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            icon_codepoint INTEGER,
            is_builtin INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY(campaign_id) REFERENCES campaigns(id) ON DELETE CASCADE,
            UNIQUE(campaign_id, name)
          )
        ''');

        // notes
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            campaign_id INTEGER NOT NULL,
            category_id INTEGER,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            favorite INTEGER NOT NULL DEFAULT 0,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            FOREIGN KEY(campaign_id) REFERENCES campaigns(id) ON DELETE CASCADE,
            FOREIGN KEY(category_id) REFERENCES categories(id) ON DELETE SET NULL
          )
        ''');

        // note_images
        await db.execute('''
          CREATE TABLE note_images (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            note_id INTEGER NOT NULL,
            path TEXT NOT NULL,
            FOREIGN KEY(note_id) REFERENCES notes(id) ON DELETE CASCADE
          )
        ''');

        // índices útiles
        await db.execute('CREATE INDEX idx_categories_campaign ON categories(campaign_id)');
        await db.execute('CREATE INDEX idx_notes_campaign ON notes(campaign_id)');
        await db.execute('CREATE INDEX idx_notes_category ON notes(category_id)');
        await db.execute('CREATE INDEX idx_images_note ON note_images(note_id)');
        await db.execute('CREATE INDEX idx_notes_title ON notes(title)');
      },
    );

    return _db!;
  }
}

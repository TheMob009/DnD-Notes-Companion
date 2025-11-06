import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const _dbName = 'dnd_notes.db';
  static const _dbVersion = 1;

  static Database? _instance;

  static Future<Database> getInstance() async {
    if (_instance != null) return _instance!;
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/$_dbName';

    _instance = await openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        // campañas
        await db.execute('''
          CREATE TABLE campaigns(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            edition TEXT,
            icon_codepoint INTEGER,
            created_at INTEGER NOT NULL
          )
        ''');

        // categorías
        await db.execute('''
          CREATE TABLE categories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            campaign_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            icon_codepoint INTEGER,
            is_builtin INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY(campaign_id) REFERENCES campaigns(id) ON DELETE CASCADE
          )
        ''');

        // notas
        await db.execute('''
          CREATE TABLE notes(
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

        // imágenes de nota (ruta local)
        await db.execute('''
          CREATE TABLE note_images(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            note_id INTEGER NOT NULL,
            path TEXT NOT NULL,
            FOREIGN KEY(note_id) REFERENCES notes(id) ON DELETE CASCADE
          )
        ''');
      },
      onUpgrade: (db, oldV, newV) async {
        // aquí irán futuras migraciones
      },
    );

    return _instance!;
  }
}

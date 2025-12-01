import 'package:sqflite/sqflite.dart';
import '../../models/note.dart';
import '../db.dart';

class NoteRepo {
  static const _notes = 'notes';
  static const _images = 'note_images';

  Future<int> insertNote({
    required int campaignId,
    int? categoryId,
    required String title,
    required String description,
    List<String> imagePaths = const [],
    bool favorite = false,
  }) async {
    final db = await AppDatabase.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;

    final noteId = await db.insert(_notes, {
      'campaign_id': campaignId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'favorite': favorite ? 1 : 0,
      'created_at': now,
      'updated_at': now,
    });

    if (imagePaths.isNotEmpty) {
      final batch = db.batch();
      for (final p in imagePaths) {
        batch.insert(_images, {'note_id': noteId, 'path': p});
      }
      await batch.commit(noResult: true);
    }

    return noteId;
  }

  Future<int> updateNote(Note n) async {
    final db = await AppDatabase.getInstance();
    final updated = n.copyWith(updatedAt: DateTime.now().millisecondsSinceEpoch);
    return db.update(_notes, updated.toMap(), where: 'id = ?', whereArgs: [n.id]);
  }

  Future<void> replaceImages(int noteId, List<String> imagePaths) async {
    final db = await AppDatabase.getInstance();
    final batch = db.batch();
    batch.delete(_images, where: 'note_id = ?', whereArgs: [noteId]);
    for (final p in imagePaths) {
      batch.insert(_images, {'note_id': noteId, 'path': p});
    }
    await batch.commit(noResult: true);
  }

  Future<int> deleteNote(int id) async {
    final db = await AppDatabase.getInstance();
    // CASCADE elimina imágenes
    return db.delete(_notes, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<String>> _getImagesFor(int noteId) async {
    final db = await AppDatabase.getInstance();
    final rows = await db.query(_images, where: 'note_id = ?', whereArgs: [noteId]);
    return rows.map((m) => m['path'] as String).toList();
    }

  Future<List<Note>> getNotesByCampaign(int campaignId) async {
    final db = await AppDatabase.getInstance();
    final rows = await db.query(
      _notes,
      where: 'campaign_id = ?',
      whereArgs: [campaignId],
      orderBy: 'favorite DESC, updated_at DESC',
    );
    final result = <Note>[];
    for (final r in rows) {
      final images = await _getImagesFor(r['id'] as int);
      result.add(Note.fromMap(r, images: images));
    }
    return result;
  }

  Future<List<Note>> getNotesByCategory(int campaignId, int categoryId) async {
    final db = await AppDatabase.getInstance();
    final rows = await db.query(
      _notes,
      where: 'campaign_id = ? AND category_id = ?',
      whereArgs: [campaignId, categoryId],
      orderBy: 'favorite DESC, updated_at DESC',
    );
    final result = <Note>[];
    for (final r in rows) {
      final images = await _getImagesFor(r['id'] as int);
      result.add(Note.fromMap(r, images: images));
    }
    return result;
  }

  Future<List<Note>> searchNotesByTitle(int campaignId, String query) async {
    final db = await AppDatabase.getInstance();
    final rows = await db.query(
      _notes,
      where: 'campaign_id = ? AND title LIKE ?',
      whereArgs: [campaignId, '%$query%'],
      orderBy: 'favorite DESC, updated_at DESC',
    );
    final result = <Note>[];
    for (final r in rows) {
      final images = await _getImagesFor(r['id'] as int);
      result.add(Note.fromMap(r, images: images));
    }
    return result;
  }

  Future<void> toggleFavorite(int noteId, bool value) async {
    final db = await AppDatabase.getInstance();
    await db.update(
      _notes,
      {
        'favorite': value ? 1 : 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }
}

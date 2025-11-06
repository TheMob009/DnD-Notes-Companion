import 'package:sqflite/sqflite.dart';
import '../../models/category.dart';
import '../db.dart';

class CategoryRepo {
  static const _table = 'categories';

  // Categorías base + Favoritos (virtual como categoría fija de UI)
  static const List<Map<String, dynamic>> _builtin = [
    {'name': 'Historia/Sesión', 'icon': 0xea19}, // Icons.menu_book
    {'name': 'Personajes', 'icon': 0xe491},      // Icons.person
    {'name': 'Ciudades', 'icon': 0xe7f1},        // Icons.location_city
    {'name': 'Lugares', 'icon': 0xeab3},         // Icons.castle
    {'name': 'Objetos', 'icon': 0xe3b1},         // Icons.shield
    {'name': 'Misiones', 'icon': 0xf052d},       // Icons.flag
  ];

  Future<void> ensureBuiltinsForCampaign(int campaignId) async {
    final db = await AppDatabase.getInstance();
    final existing = await db.query(
      _table,
      where: 'campaign_id = ? AND is_builtin = 1',
      whereArgs: [campaignId],
    );

    if (existing.isNotEmpty) return;

    final batch = db.batch();
    for (final b in _builtin) {
      batch.insert(_table, {
        'campaign_id': campaignId,
        'name': b['name'],
        'icon_codepoint': b['icon'],
        'is_builtin': 1,
      });
    }
    await batch.commit(noResult: true);
  }

  Future<int> insertCustomCategory({
    required int campaignId,
    required String name,
    int? iconCodePoint,
  }) async {
    final db = await AppDatabase.getInstance();
    return db.insert(_table, {
      'campaign_id': campaignId,
      'name': name,
      'icon_codepoint': iconCodePoint,
      'is_builtin': 0,
    });
  }

  Future<List<Category>> getByCampaign(int campaignId) async {
    final db = await AppDatabase.getInstance();
    final rows = await db.query(
      _table,
      where: 'campaign_id = ?',
      whereArgs: [campaignId],
      orderBy: 'is_builtin DESC, name ASC',
    );
    return rows.map((m) => Category.fromMap(m)).toList();
  }
}

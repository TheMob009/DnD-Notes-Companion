import 'package:sqflite/sqflite.dart';
import '../../models/campaign.dart';
import '../db.dart';
import 'category_repo.dart';

class CampaignRepo {
  static const _table = 'campaigns';

  Future<int> insertCampaign({
    required String name,
    String? edition,
    int? iconCodePoint,
  }) async {
    final db = await AppDatabase.getInstance();
    final id = await db.insert(_table, {
      'name': name,
      'edition': edition,
      'icon_codepoint': iconCodePoint,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });

    // Crear categorías built-in para la campaña
    await CategoryRepo().ensureBuiltinsForCampaign(id);
    return id;
  }

  Future<List<Campaign>> getAll() async {
    final db = await AppDatabase.getInstance();
    final rows = await db.query(_table, orderBy: 'created_at DESC');
    return rows.map((m) => Campaign.fromMap(m)).toList();
  }

  Future<int> deleteCampaign(int id) async {
    final db = await AppDatabase.getInstance();
    // ON DELETE CASCADE se encarga del resto
    return db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateCampaign(Campaign c) async {
    final db = await AppDatabase.getInstance();
    return db.update(_table, c.toMap(), where: 'id = ?', whereArgs: [c.id]);
  }
}

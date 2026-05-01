import '../../core/database/database_helper.dart';
import '../models/fasting_session_model.dart';

class FastingDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertSession(FastingSessionModel session) async {
    final db = await _dbHelper.database;
    return await db.insert('fasting_sessions', session.toMap());
  }

  Future<List<FastingSessionModel>> getSessionsByUser(int userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'fasting_sessions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'start_time DESC',
    );
    return maps.map((map) => FastingSessionModel.fromMap(map)).toList();
  }

  Future<FastingSessionModel?> getActiveSession(int userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'fasting_sessions',
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, 'active'],
    );

    if (maps.isNotEmpty) {
      return FastingSessionModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateSession(FastingSessionModel session) async {
    final db = await _dbHelper.database;
    return await db.update(
      'fasting_sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<int> deleteSession(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'fasting_sessions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<FastingSessionModel?> getLastSession(int userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'fasting_sessions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'start_time DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return FastingSessionModel.fromMap(maps.first);
    }
    return null;
  }
}

import '../../core/database/database_helper.dart';
import '../models/meal_model.dart';

class MealDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertMeal(MealModel meal) async {
    final db = await _dbHelper.database;
    return await db.insert('meals', meal.toMap());
  }

  Future<List<MealModel>> getMealsByUser(int userId, {DateTime? date}) async {
    final db = await _dbHelper.database;

    if (date != null) {
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));

      final maps = await db.query(
        'meals',
        where: 'user_id = ? AND timestamp >= ? AND timestamp < ?',
        whereArgs: [userId, start.toIso8601String(), end.toIso8601String()],
        orderBy: 'timestamp DESC',
      );
      return maps.map((map) => MealModel.fromMap(map)).toList();
    }

    final maps = await db.query(
      'meals',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => MealModel.fromMap(map)).toList();
  }

  Future<int> updateMeal(MealModel meal) async {
    final db = await _dbHelper.database;
    return await db.update(
      'meals',
      meal.toMap(),
      where: 'id = ?',
      whereArgs: [meal.id],
    );
  }

  Future<int> deleteMeal(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'meals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getTotalCaloriesForDay(int userId, DateTime date) async {
    final db = await _dbHelper.database;
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final result = await db.rawQuery(
      'SELECT SUM(calories) as total FROM meals WHERE user_id = ? AND timestamp >= ? AND timestamp < ?',
      [userId, start.toIso8601String(), end.toIso8601String()],
    );

    return result.first['total'] as int? ?? 0;
  }
}

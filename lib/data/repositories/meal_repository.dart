import '../datasources/meal_datasource.dart';
import '../models/meal_model.dart';
import '../../domain/entities/meal_entity.dart';

class MealRepository {
  final MealDataSource _dataSource = MealDataSource();

  Future<int> addMeal(MealEntity meal) async {
    final mealModel = MealModel.fromEntity(meal);
    return await _dataSource.insertMeal(mealModel);
  }

  Future<List<MealEntity>> getMeals(int userId, {DateTime? date}) async {
    final mealModels = await _dataSource.getMealsByUser(userId, date: date);
    return mealModels.map((model) => model.toEntity()).toList();
  }

  Future<int> updateMeal(MealEntity meal) async {
    final mealModel = MealModel.fromEntity(meal);
    return await _dataSource.updateMeal(mealModel);
  }

  Future<int> deleteMeal(int id) async {
    return await _dataSource.deleteMeal(id);
  }

  Future<int> getTotalCaloriesForDay(int userId, DateTime date) async {
    return await _dataSource.getTotalCaloriesForDay(userId, date);
  }
}

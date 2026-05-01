import 'package:flutter/material.dart';
import '../../domain/entities/meal_entity.dart';
import '../../domain/usecases/meal_usecases.dart';

class MealViewModel extends ChangeNotifier {
  final AddMeal _addMeal = AddMeal();
  final GetMeals _getMeals = GetMeals();
  final UpdateMeal _updateMeal = UpdateMeal();
  final DeleteMeal _deleteMeal = DeleteMeal();
  final GetTotalCaloriesForDay _getTotalCalories = GetTotalCaloriesForDay();

  List<MealEntity> _meals = [];
  bool _isLoading = false;

  List<MealEntity> get meals => _meals;
  bool get isLoading => _isLoading;

  Future<void> loadMeals(int userId, {DateTime? date}) async {
    _isLoading = true;
    notifyListeners();

    _meals = await _getMeals(userId, date: date);

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addMeal(MealEntity meal) async {
    try {
      await _addMeal(meal);
      await loadMeals(meal.userId, date: meal.timestamp);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateMeal(MealEntity meal) async {
    try {
      await _updateMeal(meal);
      await loadMeals(meal.userId, date: meal.timestamp);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteMeal(int id, int userId, DateTime date) async {
    try {
      await _deleteMeal(id);
      await loadMeals(userId, date: date);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int> getTotalCaloriesForDay(int userId, DateTime date) async {
    return await _getTotalCalories(userId, date);
  }
}

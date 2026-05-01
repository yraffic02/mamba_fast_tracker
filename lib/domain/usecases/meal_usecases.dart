import '../../data/repositories/meal_repository.dart';
import '../../domain/entities/meal_entity.dart';

class AddMeal {
  final MealRepository _repository = MealRepository();

  Future<int> call(MealEntity meal) async {
    return await _repository.addMeal(meal);
  }
}

class GetMeals {
  final MealRepository _repository = MealRepository();

  Future<List<MealEntity>> call(int userId, {DateTime? date}) async {
    return await _repository.getMeals(userId, date: date);
  }
}

class UpdateMeal {
  final MealRepository _repository = MealRepository();

  Future<int> call(MealEntity meal) async {
    return await _repository.updateMeal(meal);
  }
}

class DeleteMeal {
  final MealRepository _repository = MealRepository();

  Future<int> call(int id) async {
    return await _repository.deleteMeal(id);
  }
}

class GetTotalCaloriesForDay {
  final MealRepository _repository = MealRepository();

  Future<int> call(int userId, DateTime date) async {
    return await _repository.getTotalCaloriesForDay(userId, date);
  }
}

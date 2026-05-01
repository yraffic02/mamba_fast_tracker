import '../../domain/entities/meal_entity.dart';

class MealModel {
  final int? id;
  final int userId;
  final String name;
  final int calories;
  final String timestamp;

  MealModel({
    this.id,
    required this.userId,
    required this.name,
    required this.calories,
    required this.timestamp,
  });

  factory MealModel.fromEntity(MealEntity entity) {
    return MealModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      calories: entity.calories,
      timestamp: entity.timestamp.toIso8601String(),
    );
  }

  MealEntity toEntity() {
    return MealEntity(
      id: id,
      userId: userId,
      name: name,
      calories: calories,
      timestamp: DateTime.parse(timestamp),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'calories': calories,
      'timestamp': timestamp,
    };
  }

  factory MealModel.fromMap(Map<String, dynamic> map) {
    return MealModel(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      calories: map['calories'],
      timestamp: map['timestamp'],
    );
  }
}

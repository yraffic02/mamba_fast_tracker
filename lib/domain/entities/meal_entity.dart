class MealEntity {
  final int? id;
  final int userId;
  final String name;
  final int calories;
  final DateTime timestamp;

  MealEntity({
    this.id,
    required this.userId,
    required this.name,
    required this.calories,
    required this.timestamp,
  });
}

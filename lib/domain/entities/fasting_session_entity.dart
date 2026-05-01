class FastingSessionEntity {
  final int? id;
  final int userId;
  final DateTime startTime;
  final DateTime? endTime;
  final String status;

  FastingSessionEntity({
    this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.status,
  });
}

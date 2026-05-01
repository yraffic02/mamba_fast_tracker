import '../../domain/entities/fasting_session_entity.dart';

class FastingSessionModel {
  final int? id;
  final int userId;
  final String startTime;
  final String? endTime;
  final String status;

  FastingSessionModel({
    this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.status,
  });

  factory FastingSessionModel.fromEntity(FastingSessionEntity entity) {
    return FastingSessionModel(
      id: entity.id,
      userId: entity.userId,
      startTime: entity.startTime.toIso8601String(),
      endTime: entity.endTime?.toIso8601String(),
      status: entity.status,
    );
  }

  FastingSessionEntity toEntity() {
    return FastingSessionEntity(
      id: id,
      userId: userId,
      startTime: DateTime.parse(startTime),
      endTime: endTime != null ? DateTime.parse(endTime!) : null,
      status: status,
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'user_id': userId,
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
    };
    if (id != null) {
      map['id'] = id!;
    }
    return map;
  }

  factory FastingSessionModel.fromMap(Map<String, dynamic> map) {
    return FastingSessionModel(
      id: map['id'],
      userId: map['user_id'],
      startTime: map['start_time'],
      endTime: map['end_time'],
      status: map['status'],
    );
  }
}

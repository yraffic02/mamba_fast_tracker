import '../datasources/fasting_datasource.dart';
import '../models/fasting_session_model.dart';
import '../../domain/entities/fasting_session_entity.dart';

class FastingRepository {
  final FastingDataSource _dataSource = FastingDataSource();

  Future<int> startFasting(int userId) async {
    final session = FastingSessionModel(
      userId: userId,
      startTime: DateTime.now().toIso8601String(),
      status: 'active',
    );
    return await _dataSource.insertSession(session);
  }

  Future<int> endFasting(int userId) async {
    final activeSession = await _dataSource.getActiveSession(userId);
    if (activeSession != null) {
      final updatedSession = FastingSessionModel(
        id: activeSession.id,
        userId: userId,
        startTime: activeSession.startTime,
        endTime: DateTime.now().toIso8601String(),
        status: 'completed',
      );
      return await _dataSource.updateSession(updatedSession);
    }
    return 0;
  }

  Future<FastingSessionEntity?> getActiveSession(int userId) async {
    final session = await _dataSource.getActiveSession(userId);
    return session?.toEntity();
  }

  Future<FastingSessionEntity?> getLastSession(int userId) async {
    final session = await _dataSource.getLastSession(userId);
    return session?.toEntity();
  }

  Duration? getElapsedTime(FastingSessionEntity session) {
    if (session.endTime != null) {
      return session.endTime!.difference(session.startTime);
    }
    return DateTime.now().difference(session.startTime);
  }
}

import '../../data/repositories/fasting_repository.dart';
import '../../domain/entities/fasting_session_entity.dart';

class StartFasting {
  final FastingRepository _repository = FastingRepository();

  Future<int> call(int userId) async {
    return await _repository.startFasting(userId);
  }
}

class EndFasting {
  final FastingRepository _repository = FastingRepository();

  Future<int> call(int userId) async {
    return await _repository.endFasting(userId);
  }
}

class GetActiveFastingSession {
  final FastingRepository _repository = FastingRepository();

  Future<FastingSessionEntity?> call(int userId) async {
    return await _repository.getActiveSession(userId);
  }
}

class GetLastFastingSession {
  final FastingRepository _repository = FastingRepository();

  Future<FastingSessionEntity?> call(int userId) async {
    return await _repository.getLastSession(userId);
  }
}

class GetElapsedTime {
  final FastingRepository _repository = FastingRepository();

  Duration? call(FastingSessionEntity session) {
    return _repository.getElapsedTime(session);
  }
}

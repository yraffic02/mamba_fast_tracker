import 'package:flutter/material.dart';
import '../../domain/entities/fasting_session_entity.dart';
import '../../domain/usecases/fasting_usecases.dart';
import '../../core/services/notification_service.dart';

class FastingViewModel extends ChangeNotifier {
  final StartFasting _startFasting = StartFasting();
  final EndFasting _endFasting = EndFasting();
  final GetActiveFastingSession _getActiveSession = GetActiveFastingSession();
  final GetLastFastingSession _getLastSession = GetLastFastingSession();
  final GetElapsedTime _getElapsedTime = GetElapsedTime();
  final NotificationService _notificationService = NotificationService.instance;

  FastingSessionEntity? _currentSession;
  bool _isLoading = false;

  FastingSessionEntity? get currentSession => _currentSession;
  bool get isLoading => _isLoading;
  bool get isFasting => _currentSession != null && _currentSession!.endTime == null;

  Duration get elapsedTime {
    if (_currentSession == null) return Duration.zero;
    return _getElapsedTime(_currentSession!) ?? Duration.zero;
  }

  Future<void> loadActiveSession(int userId) async {
    _isLoading = true;
    notifyListeners();

    _currentSession = await _getActiveSession(userId);

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> startFasting(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _startFasting(userId);
      try {
        await _notificationService.notifyFastingStarted();
      } catch (_) {}
      await loadActiveSession(userId);
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> endFasting(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _endFasting(userId);
      try {
        await _notificationService.notifyFastingEnded();
      } catch (_) {}
      _currentSession = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<FastingSessionEntity?> getLastSession(int userId) async {
    return await _getLastSession(userId);
  }
}

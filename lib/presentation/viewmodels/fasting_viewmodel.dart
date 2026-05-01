import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/fasting_session_entity.dart';
import '../../domain/entities/fasting_protocol_entity.dart';
import '../../domain/usecases/fasting_usecases.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/session_service.dart';

class FastingViewModel extends ChangeNotifier {
  final StartFasting _startFasting = StartFasting();
  final EndFasting _endFasting = EndFasting();
  final GetActiveFastingSession _getActiveSession = GetActiveFastingSession();
  final GetLastFastingSession _getLastSession = GetLastFastingSession();
  final GetElapsedTime _getElapsedTime = GetElapsedTime();
  final NotificationService _notificationService = NotificationService.instance;
  final SessionService _sessionService = SessionService();

  FastingSessionEntity? _currentSession;
  bool _isLoading = false;
  Timer? _timer;
  String _currentProtocol = '16:8';
  bool _goalNotified = false;

  FastingSessionEntity? get currentSession => _currentSession;
  bool get isLoading => _isLoading;
  bool get isFasting => _currentSession != null && _currentSession!.endTime == null;
  String get currentProtocol => _currentProtocol;
  FastingProtocol get protocol => FastingProtocol.protocols.firstWhere(
        (p) => p.name == _currentProtocol,
        orElse: () => FastingProtocol.defaultProtocol,
      );

  Duration get elapsedTime {
    if (_currentSession == null) return Duration.zero;
    return _getElapsedTime(_currentSession!) ?? Duration.zero;
  }

  Duration get remainingTime {
    if (_currentSession == null) return Duration.zero;
    final elapsed = elapsedTime;
    final target = protocol.fastingDuration;
    if (elapsed >= target) return Duration.zero;
    return target - elapsed;
  }

  bool get isGoalReached {
    if (_currentSession == null) return false;
    return elapsedTime >= protocol.fastingDuration;
  }

  Future<void> loadProtocol() async {
    _currentProtocol = await _sessionService.getFastingProtocol();
    notifyListeners();
  }

  Future<void> setProtocol(String protocolName) async {
    _currentProtocol = protocolName;
    await _sessionService.saveFastingProtocol(protocolName);
    notifyListeners();
  }

  Future<DateTime?> getScheduledStartTime() async {
    return await _sessionService.getScheduledStartTime();
  }

  Future<void> saveScheduledStartTime(DateTime startTime) async {
    await _sessionService.saveScheduledStartTime(startTime);
  }

  Future<void> clearScheduledStartTime() async {
    await _sessionService.clearScheduledStartTime();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_currentSession != null && _currentSession!.endTime == null) {
        if (isGoalReached && !_goalNotified) {
          _goalNotified = true;
          _notificationService.notifyFastingGoalReached();
        }
        notifyListeners();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _goalNotified = false;
  }

  Future<void> loadActiveSession(int userId) async {
    _isLoading = true;
    notifyListeners();

    await loadProtocol();
    _currentSession = await _getActiveSession(userId);

    if (_currentSession != null && _currentSession!.endTime == null) {
      _startTimer();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> startFasting(int userId) async {
    final scheduledStart = await _sessionService.getScheduledStartTime();
    if (scheduledStart == null) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _startFasting(userId);
      try {
        await _notificationService.notifyFastingStarted();

        final session = _currentSession;
        if (session != null) {
          final endTime = session.startTime.add(protocol.fastingDuration);

          // 5min antes de terminar
          final fiveMinBeforeEnd = endTime.subtract(const Duration(minutes: 5));
          if (fiveMinBeforeEnd.isAfter(DateTime.now())) {
            await _notificationService.scheduleNotification(
              'Jejum Termina em 5min',
              'Seu jejum de ${protocol.name} termina em 5 minutos!',
              fiveMinBeforeEnd,
            );
          }

          // Na hora de terminar
          await _notificationService.scheduleNotification(
            'Jejum Concluído',
            'Seu jejum de ${protocol.name} terminou!',
            endTime,
          );

          // 5min antes de começar (se agendado)
          final fiveMinBeforeStart = scheduledStart.subtract(const Duration(minutes: 5));
          if (fiveMinBeforeStart.isAfter(DateTime.now())) {
            await _notificationService.scheduleNotification(
              'Jejum Começa em 5min',
              'Seu jejum de ${protocol.name} começa em 5 minutos!',
              fiveMinBeforeStart,
            );
          }
        }
      } catch (_) {}
      await _sessionService.clearScheduledStartTime();
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
      _stopTimer();
      try {
        await _notificationService.notifyFastingEnded();
        await _notificationService.cancelAllNotifications();
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

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}

    int _notificationId = 100; // ID base para notificações

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
              await _notificationService.scheduleOneTimeNotification(
                id: _notificationId++,
                title: 'Jejum Termina em 5min',
                body: 'Seu jejum de ${protocol.name} termina em 5 minutos!',
                scheduledDate: fiveMinBeforeEnd,
              );
            }

            // Na hora de terminar
            await _notificationService.scheduleOneTimeNotification(
              id: _notificationId++,
              title: 'Jejum Concluído',
              body: 'Seu jejum de ${protocol.name} terminou!',
              scheduledDate: endTime,
            );

            // 5min antes de começar (se agendado)
            final fiveMinBeforeStart = scheduledStart.subtract(const Duration(minutes: 5));
            if (fiveMinBeforeStart.isAfter(DateTime.now())) {
              await _notificationService.scheduleOneTimeNotification(
                id: _notificationId++,
                title: 'Jejum Começa em 5min',
                body: 'Seu jejum de ${protocol.name} começa em 5 minutos!',
                scheduledDate: fiveMinBeforeStart,
              );
            }

            // Agenda para os próximos dias (repetição diária)
            await _scheduleDailyNotificationsForProtocol();
          }
        } catch (e) {
          // Erro ao agendar notificações
        }
        await _sessionService.clearScheduledStartTime();
        await loadActiveSession(userId);
        return true;
      } catch (e) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    }
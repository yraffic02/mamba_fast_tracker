import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/fasting_protocol_entity.dart';
import '../viewmodels/fasting_viewmodel.dart';
import '../../core/services/notification_service.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  DateTime? _scheduledStartTime;
  int _numberOfDays = 1;

  @override
  void initState() {
    super.initState();
    _loadScheduledTime();
  }

  Future<void> _loadScheduledTime() async {
    final viewModel = Provider.of<FastingViewModel>(context, listen: false);
    _scheduledStartTime = await viewModel.getScheduledStartTime();
    if (mounted) setState(() {});
  }

  Future<void> _pickStartTime() async {
    final now = DateTime.now();
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );

    if (time != null && mounted) {
      // Cria DateTime apenas com hora/minuto (mantém dia atual)
      var scheduledDate = DateTime(now.year, now.month, now.day, time.hour, time.minute);

      // Verifica se já passou hoje
      bool timePassedToday = scheduledDate.isBefore(now);

      if (timePassedToday) {
        // Mostra diálogo informando que o horário já passou
        final shouldStartAnyway = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Horário já passou'),
            content: Text(
                'O horário ${DateFormat('HH:mm').format(scheduledDate)} já passou hoje.\n\n'
                'Deseja iniciar o jejum mesmo assim?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Iniciar Mesmo Assim'),
              ),
            ],
          ),
        );

        if (shouldStartAnyway != true) {
          return; // Usuário cancelou
        }
        // Agenda para agora (início imediato)
        scheduledDate = now;
      }

      // Pergunta quantos dias
      final days = await _askNumberOfDays();
      if (days == null || days <= 0) return;

      setState(() {
        _scheduledStartTime = scheduledDate;
        _numberOfDays = days;
      });

      final viewModel = Provider.of<FastingViewModel>(context, listen: false);
      await viewModel.saveScheduledStartTime(scheduledDate);

      // Agenda notificações para os dias selecionados
      await _scheduleNotificationsForDays(scheduledDate, days, viewModel.currentProtocol);

      if (context.mounted) {
        final formattedTime = DateFormat('HH:mm').format(scheduledDate);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Jejum agendado para $formattedTime por $days dia(s)',
            ),
          ),
        );
      }
    }
  }

  Future<int?> _askNumberOfDays() async {
    int? selectedDays;
    await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Quantos dias?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Selecione por quantos dias deseja agendar:'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [1, 2, 3, 5, 7].map((days) {
                  return ChoiceChip(
                    label: Text('$days ${days == 1 ? 'dia' : 'dias'}'),
                    selected: selectedDays == days,
                    onSelected: (selected) {
                      if (selected) {
                        selectedDays = days;
                        Navigator.pop(context, days);
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
    return selectedDays;
  }

  int _notificationId = 100; // ID base para notificações

  Future<void> _scheduleNotificationsForDays(
    DateTime startTime,
    int days,
    String protocolName,
  ) async {
    final notificationService = NotificationService.instance;
    final protocol = FastingProtocol.protocols.firstWhere(
      (p) => p.name == protocolName,
      orElse: () => FastingProtocol.defaultProtocol,
    );
    final fastingHours = protocol.fastingHours;

    // Cancela notificações anteriores
    await notificationService.cancelAllNotifications();

    for (int day = 0; day < days; day++) {
      final dayStart = startTime.add(Duration(days: day));
      final dayEnd = dayStart.add(Duration(hours: fastingHours));

      // 5min antes de começar
      final fiveMinBeforeStart = dayStart.subtract(const Duration(minutes: 5));
      if (fiveMinBeforeStart.isAfter(DateTime.now())) {
        await notificationService.scheduleOneTimeNotification(
          id: _notificationId++,
          title: 'Jejum Começa em 5min',
          body: 'Seu jejum de $protocolName começa em 5 minutos!',
          scheduledDate: fiveMinBeforeStart,
        );
      }

      // Na hora de começar
      if (dayStart.isAfter(DateTime.now())) {
        await notificationService.scheduleOneTimeNotification(
          id: _notificationId++,
          title: 'Jejum Iniciado',
          body: 'Seu jejum de $protocolName começou!',
          scheduledDate: dayStart,
        );
      }

      // 5min antes de terminar
      final fiveMinBeforeEnd = dayEnd.subtract(const Duration(minutes: 5));
      if (fiveMinBeforeEnd.isAfter(DateTime.now())) {
        await notificationService.scheduleOneTimeNotification(
          id: _notificationId++,
          title: 'Jejum Termina em 5min',
          body: 'Seu jejum de $protocolName termina em 5 minutos!',
          scheduledDate: fiveMinBeforeEnd,
        );
      }

      // Na hora de terminar
      if (dayEnd.isAfter(DateTime.now())) {
        await notificationService.scheduleOneTimeNotification(
          id: _notificationId++,
          title: 'Jejum Concluído',
          body: 'Seu jejum de $protocolName terminou!',
          scheduledDate: dayEnd,
        );
      }
    }

    // Agenda notificação diária para repetir todos os dias no mesmo horário (5min antes)
    final fiveMinBeforeDaily = startTime.subtract(const Duration(minutes: 5));
    await notificationService.scheduleDailyNotification(
      id: _notificationId++,
      title: 'Jejum Começa em 5min',
      body: 'Seu jejum de $protocolName começa em 5 minutos!',
      hour: fiveMinBeforeDaily.hour,
      minute: fiveMinBeforeDaily.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: Consumer<FastingViewModel>(
        builder: (context, viewModel, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Protocolo de Jejum',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                'Selecione o protocolo que deseja seguir:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ...FastingProtocol.protocols.map((protocol) {
                final isSelected = viewModel.currentProtocol == protocol.name;
                return Card(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  child: ListTile(
                    title: Text(protocol.name),
                    subtitle: Text(protocol.description),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () async {
                      await viewModel.setProtocol(protocol.name);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Protocolo ${protocol.name} selecionado'),
                          ),
                        );
                      }
                    },
                  ),
                );
              }),
              const SizedBox(height: 32),
              Text(
                'Horário de Início',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                'Agende que horas deseja iniciar o jejum (formato 24h):',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              if (_scheduledStartTime != null) ...[
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(_scheduledStartTime!),
                  ),
                  subtitle: Text('$_numberOfDays dia(s) agendado(s)'),
                ),
                const SizedBox(height: 8),
              ],
              ElevatedButton(
                onPressed: _pickStartTime,
                child: Text(_scheduledStartTime == null
                    ? 'Agendar Início'
                    : 'Alterar Horário'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  await NotificationService.instance.showNotification(
                    'Teste de Notificação',
                    'Se esta notificação apareceu, o canal está funcionando!',
                  );
                },
                child: const Text('Testar Notificação Agora'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  // Solicita permissões de notificação e alarme exato
                  await NotificationService.instance.requestNotificationPermissions();
                  // Verifica se foi concedida
                  final hasPermission = await NotificationService.instance.areNotificationsEnabled();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(hasPermission
                            ? 'Permissões concedidas!'
                            : 'Permissões negadas. Vá em Configurações > Apps > Mamba Fast Tracker > Alarmes exatos'),
                      ),
                    );
                  }
                },
                child: const Text('Solicitar Permissões'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  await NotificationService.instance.openSettings();
                },
                child: const Text('Abrir Config. do App'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

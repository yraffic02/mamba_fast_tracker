import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/fasting_protocol_entity.dart';
import '../viewmodels/fasting_viewmodel.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  DateTime? _scheduledStartTime;

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
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 7)),
    );
    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
      );
      if (time != null && mounted) {
        setState(() {
          _scheduledStartTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
        final viewModel =
            Provider.of<FastingViewModel>(context, listen: false);
        await viewModel.saveScheduledStartTime(_scheduledStartTime!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Jejum agendado para ${DateFormat('dd/MM/yyyy HH:mm').format(_scheduledStartTime!)}'),
            ),
          );
        }
      }
    }
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
                            content:
                                Text('Protocolo ${protocol.name} selecionado'),
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
                'Agende quando deseja iniciar o jejum:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              if (_scheduledStartTime != null) ...[
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text(
                    DateFormat('dd/MM/yyyy HH:mm')
                        .format(_scheduledStartTime!),
                  ),
                  subtitle: const Text('Horário agendado'),
                ),
                const SizedBox(height: 8),
              ],
              ElevatedButton(
                onPressed: _pickStartTime,
                child: Text(_scheduledStartTime == null
                    ? 'Agendar Início'
                    : 'Alterar Horário'),
              ),
            ],
          );
        },
      ),
    );
  }
}

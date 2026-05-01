import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/fasting_protocol_entity.dart';
import '../viewmodels/fasting_viewmodel.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

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
            ],
          );
        },
      ),
    );
  }
}

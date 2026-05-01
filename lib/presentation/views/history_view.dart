import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/fasting_session_entity.dart';
import '../../domain/entities/fasting_protocol_entity.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/fasting_viewmodel.dart';
import '../widgets/fasting_chart.dart';
import '../widgets/calories_chart.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  int? _userId;
  FastingSessionEntity? _lastSession;
  FastingProtocol? _protocol;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final fastVM = Provider.of<FastingViewModel>(context, listen: false);

    _userId = await authVM.getLoggedUserId();
    if (_userId != null && mounted) {
      _lastSession = await fastVM.getLastSession(_userId!);
      _protocol = fastVM.protocol;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Refeições'),
                Tab(text: 'Jejum'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _MealsHistoryTab(userId: _userId!),
                  if (_lastSession != null)
                    _FastingHistoryTab(
                      session: _lastSession!,
                      protocol: _protocol ?? FastingProtocol.defaultProtocol,
                    )
                  else
                    const Center(child: Text('Nenhum histórico de jejum')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealsHistoryTab extends StatefulWidget {
  final int userId;
  const _MealsHistoryTab({required this.userId});

  @override
  State<_MealsHistoryTab> createState() => _MealsHistoryTabState();
}

class _MealsHistoryTabState extends State<_MealsHistoryTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<MealViewModel>(context, listen: false).loadMeals(widget.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MealViewModel>(
      builder: (context, mealViewModel, _) {
        final meals = mealViewModel.meals;
        final isLoading = mealViewModel.isLoading;

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (meals.isEmpty) {
          return const Center(child: Text('Nenhuma refeição registrada'));
        }

        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Calorias Diárias (Últimos 7 Dias)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            CaloriesChart(meals: meals, referenceDate: DateTime.now()),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
                return ListTile(
                  title: Text(meal.name),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(meal.timestamp),
                  ),
                  trailing: Text('${meal.calories} cal'),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _FastingHistoryTab extends StatelessWidget {
  final FastingSessionEntity session;
  final FastingProtocol protocol;

  const _FastingHistoryTab({
    required this.session,
    required this.protocol,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = session.endTime != null;

    // Calcula duraço real
    final actualDuration = isCompleted
        ? session.endTime!.difference(session.startTime)
        : DateTime.now().difference(session.startTime);

    // Margem de 3 minutos
    final margin = const Duration(minutes: 3);

    // Status de meta
    bool isWithinMeta;

    if (isCompleted) {
      // Finalizou: verifica se atingiu a duraço do protocolo (com margem)
      isWithinMeta =
          actualDuration >= protocol.fastingDuration - margin;
    } else {
      // Ainda ativo: considera "dentro" se não houver atraso significativo
      isWithinMeta = true; // Jejum ativo é considerado dentro da meta
    }

    final statusColor = isWithinMeta ? Colors.green : Colors.yellow;
    final statusText = isWithinMeta ? 'Dentro da Meta' : 'Fora da Meta';

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Duração do Jejum',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        FastingChart(sessions: [session]),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Sessão de Jejum'),
          subtitle: Text(
            '${DateFormat('dd/MM/yyyy HH:mm').format(session.startTime)} - '
            '${isCompleted ? DateFormat('dd/MM/yyyy HH:mm').format(session.endTime!) : 'Ativo'}',
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${actualDuration.inHours}h ${actualDuration.inMinutes % 60}m',
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

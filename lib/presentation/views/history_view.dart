import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/fasting_session_entity.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/meal_viewmodel.dart';
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

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    _userId = await authViewModel.getLoggedUserId();
    if (mounted) setState(() {});
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
                  _FastingHistoryTab(userId: _userId!),
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
        Provider.of<MealViewModel>(context, listen: false)
            .loadMeals(widget.userId);
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
                  subtitle:
                      Text(DateFormat('dd/MM/yyyy HH:mm').format(meal.timestamp)),
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
  final int userId;
  const _FastingHistoryTab({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Consumer<FastingViewModel>(
      builder: (context, fastingViewModel, _) {
        return FutureBuilder<FastingSessionEntity?>(
          future: fastingViewModel.getLastSession(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final session = snapshot.data;
            if (session == null) {
              return const Center(child: Text('Nenhum histórico de jejum'));
            }

            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Duração do Jejum (Últimos 7 Dias)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                FastingChart(sessions: [session]),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Sessão de Jejum'),
                  subtitle: Text(
                    '${DateFormat('dd/MM/yyyy').format(session.startTime)} - ${session.endTime != null ? DateFormat('dd/MM/yyyy').format(session.endTime!) : 'Ativo'}',
                  ),
                  trailing: Builder(
                    builder: (context) {
                      final duration = session.endTime != null
                          ? session.endTime!
                              .difference(session.startTime)
                          : DateTime.now()
                              .difference(session.startTime);
                      return Text(
                          '${duration.inHours}h ${duration.inMinutes % 60}m');
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

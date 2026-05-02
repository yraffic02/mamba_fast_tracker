import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/fasting_viewmodel.dart';
import '../viewmodels/meal_viewmodel.dart';
import '../../core/services/notification_service.dart';
import 'add_meal_view.dart';
import 'history_view.dart';
import 'meals_list_view.dart';
import 'settings_view.dart';
import 'auth_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserAndData();
  }

  Future<void> _loadUserAndData() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final fastingViewModel =
        Provider.of<FastingViewModel>(context, listen: false);
    final mealViewModel = Provider.of<MealViewModel>(context, listen: false);

    _userId = await authViewModel.getLoggedUserId();
    if (_userId != null) {
      await fastingViewModel.loadActiveSession(_userId!);
      await mealViewModel.loadMeals(_userId!, date: DateTime.now());
    }

    // Verifica e solicita permissão de notificações
    final notificationService = NotificationService.instance;
    final enabled = await notificationService.areNotificationsEnabled();
    if (!enabled && mounted) {
      await notificationService.requestNotificationPermissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mamba Fast Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthViewModel>(context, listen: false).logout();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginView()),
                );
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              child: Text(
                'Mamba Fast Tracker',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              decoration: BoxDecoration(
                color: Colors.green,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Protocolo de Jejum'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsView(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Histórico'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryView(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: const Text('Refeições'),
              onTap: () {
                Navigator.pop(context);
                if (_userId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MealsListView(userId: _userId!),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_userId != null && mounted) {
            await Provider.of<FastingViewModel>(context, listen: false)
                .loadActiveSession(_userId!);
            if (mounted) {
              await Provider.of<MealViewModel>(context, listen: false)
                  .loadMeals(_userId!, date: DateTime.now());
            }
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildFastingSection(),
            const SizedBox(height: 24),
            _buildMealsSection(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_userId != null) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddMealView(userId: _userId!),
              ),
            );
            if (_userId != null && mounted) {
              Provider.of<MealViewModel>(context, listen: false)
                  .loadMeals(_userId!, date: DateTime.now());
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFastingSection() {
    return Consumer<FastingViewModel>(
      builder: (context, viewModel, child) {
        final isFasting = viewModel.isFasting;
        final elapsed = viewModel.elapsedTime;
        final remaining = viewModel.remainingTime;
        final goalReached = viewModel.isGoalReached;
        final protocol = viewModel.protocol;

        final progress = elapsed.inSeconds /
            (protocol.fastingDuration.inSeconds == 0
                ? 1
                : protocol.fastingDuration.inSeconds);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tempo de Jejum',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Chip(
                      label: Text(protocol.name),
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (isFasting) ...[
                  Text(
                    '${elapsed.inHours}h ${elapsed.inMinutes % 60}m ${elapsed.inSeconds % 60}s',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  if (!goalReached) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Restam: ${remaining.inHours}h ${remaining.inMinutes % 60}m',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Dentro da Meta',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 8),
                    Text(
                      'Meta atingida! 🎉',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _userId != null
                        ? () async {
                            await viewModel.endFasting(_userId!);
                            if (context.mounted) {
                              await viewModel.loadActiveSession(_userId!);
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Finalizar Jejum'),
                  ),
                ] else ...[
                  Text(
                    'Protocolo: ${protocol.name} (${protocol.fastingHours}h jejum)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _userId != null
                        ? () async {
                            final success =
                                await viewModel.startFasting(_userId!);
                            if (context.mounted) {
                              if (!success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Agende um horário de início nas Configurações'),
                                  ),
                                );
                              } else {
                                await viewModel.loadActiveSession(_userId!);
                              }
                            }
                          }
                        : null,
                    child: const Text('Iniciar Jejum'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMealsSection(BuildContext context) {
    return Consumer<MealViewModel>(
      builder: (context, viewModel, child) {
        final meals = viewModel.meals;
        final totalCalories = meals.fold<int>(
          0,
          (sum, meal) => sum + meal.calories,
        );

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Refeições de Hoje',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      '$totalCalories cal',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (meals.isEmpty)
                  Column(
                    children: [
                      const Text('Nenhuma refeição registrada hoje'),
                      const SizedBox(height: 8),
                      _buildViewAllMealsButton(),
                    ],
                  )
                else
                  Column(
                    children: [
                      ...meals.map((meal) => ListTile(
                            title: Text(meal.name),
                            subtitle: Text(
                              DateFormat('HH:mm').format(meal.timestamp),
                            ),
                            trailing: Text('${meal.calories} cal'),
                          )),
                      const SizedBox(height: 8),
                      _buildViewAllMealsButton(),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildViewAllMealsButton() {
    return Center(
      child: TextButton(
        onPressed: () {
          if (_userId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MealsListView(userId: _userId!),
              ),
            );
          }
        },
        child: const Text('Ver todas as refeições'),
      ),
    );
  }
}

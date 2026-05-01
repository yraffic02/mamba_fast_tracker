import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/meal_entity.dart';
import '../viewmodels/meal_viewmodel.dart';

class MealsListView extends StatefulWidget {
  const MealsListView({super.key});

  @override
  State<MealsListView> createState() => _MealsListViewState();
}

class _MealsListViewState extends State<MealsListView> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
      final userId =
          Provider.of<MealViewModel>(context, listen: false).getLoggedUserId();
      if (userId != null) {
        Provider.of<MealViewModel>(context, listen: false)
            .loadMeals(userId, date: _selectedDate);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refeições'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _pickDate(context),
          ),
        ],
      ),
      body: Consumer<MealViewModel>(
        builder: (context, viewModel, _) {
          final meals = viewModel.meals;
          final isLoading = viewModel.isLoading;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (meals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Nenhuma refeição em ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _pickDate(context),
                    child: const Text('Selecionar outra data'),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Refeições de ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    final meal = meals[index];
                    return Card(
                      child: ListTile(
                        title: Text(meal.name),
                        subtitle: Text(
                          DateFormat('HH:mm').format(meal.timestamp),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${meal.calories} cal',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                // TODO: Navigate to edit meal view
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Editar em breve'),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirmar'),
                                    content: const Text(
                                        'Deseja excluir esta refeição?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Excluir'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmed == true) {
                                  final userId =
                                      Provider.of<AuthViewModel>(context,
                                              listen: false)
                                          .getLoggedUserId();
                                  if (userId != null && mounted) {
                                    await viewModel.deleteMeal(
                                      meal.id!,
                                      userId,
                                      meal.timestamp,
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

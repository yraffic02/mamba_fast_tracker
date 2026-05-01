import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/meal_entity.dart';
import '../viewmodels/meal_viewmodel.dart';

class AddMealView extends StatefulWidget {
  final int userId;

  const AddMealView({super.key, required this.userId});

  @override
  State<AddMealView> createState() => _AddMealViewState();
}

class _AddMealViewState extends State<AddMealView> {
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Refeição')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome da Refeição',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _caloriesController,
              decoration: const InputDecoration(
                labelText: 'Calorias',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final name = _nameController.text;
                final calories = int.tryParse(_caloriesController.text) ?? 0;

                if (name.isNotEmpty && calories > 0) {
                  final mealViewModel =
                      Provider.of<MealViewModel>(context, listen: false);
                  await mealViewModel.addMeal(
                    MealEntity(
                      userId: widget.userId,
                      name: name,
                      calories: calories,
                      timestamp: DateTime.now(),
                    ),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('Salvar Refeição'),
            ),
          ],
        ),
      ),
    );
  }
}

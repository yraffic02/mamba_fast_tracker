import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/meal_entity.dart';
import '../viewmodels/meal_viewmodel.dart';

class EditMealView extends StatefulWidget {
  final MealEntity meal;
  const EditMealView({super.key, required this.meal});

  @override
  State<EditMealView> createState() => _EditMealViewState();
}

class _EditMealViewState extends State<EditMealView> {
  late final TextEditingController _nameController;
  late final TextEditingController _caloriesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.meal.name);
    _caloriesController =
        TextEditingController(text: widget.meal.calories.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Refeição'),
      ),
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
                final calories =
                    int.tryParse(_caloriesController.text) ?? 0;

                if (name.isNotEmpty && calories > 0) {
                  final updatedMeal = MealEntity(
                    id: widget.meal.id,
                    userId: widget.meal.userId,
                    name: name,
                    calories: calories,
                    timestamp: widget.meal.timestamp,
                  );

                  final mealViewModel =
                      Provider.of<MealViewModel>(context, listen: false);
                  final success =
                      await mealViewModel.updateMeal(updatedMeal);

                  if (context.mounted) {
                    if (success) {
                      Navigator.pop(context, true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Refeição atualizada!'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Erro ao atualizar refeição'),
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }
}

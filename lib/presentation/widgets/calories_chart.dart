import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/meal_entity.dart';

class CaloriesChart extends StatelessWidget {
  final List<MealEntity> meals;
  final DateTime referenceDate;

  const CaloriesChart({
    super.key,
    required this.meals,
    required this.referenceDate,
  });

  @override
  Widget build(BuildContext context) {
    final dailyCalories = _calculateDailyCalories();

    if (dailyCalories.isEmpty) {
      return const Center(child: Text('Sem dados para o gráfico'));
    }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxCalories(dailyCalories) + 500,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 &&
                      value.toInt() < dailyCalories.length) {
                    final dayLabel = dailyCalories[value.toInt()].dayLabel;
                    return Text(dayLabel);
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text('${value.toInt()}');
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: _buildBarGroups(dailyCalories),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(List<_DailyCalories> data) {
    List<BarChartGroupData> groups = [];
    for (int i = 0; i < data.length; i++) {
      final entry = data[i];
      final calories = entry.calories;

      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: calories.toDouble(),
              color: calories > 2000 ? Colors.red : Colors.green,
              width: 20,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }
    return groups;
  }

  List<_DailyCalories> _calculateDailyCalories() {
    final Map<String, int> caloriesByDay = {};

    for (var meal in meals) {
      final dayKey = DateFormat('E', 'pt_BR').format(meal.timestamp);
      caloriesByDay[dayKey] = (caloriesByDay[dayKey] ?? 0) + meal.calories;
    }

    return caloriesByDay.entries
        .map((e) => _DailyCalories(e.key, e.value))
        .toList();
  }

  double _getMaxCalories(List<_DailyCalories> data) {
    double max = 0;
    for (var entry in data) {
      if (entry.calories > max) max = entry.calories.toDouble();
    }
    return max;
  }
}

class _DailyCalories {
  final String dayLabel;
  final int calories;

  _DailyCalories(this.dayLabel, this.calories);
}

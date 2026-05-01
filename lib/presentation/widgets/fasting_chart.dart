import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/fasting_session_entity.dart';

class FastingChart extends StatelessWidget {
  final List<FastingSessionEntity> sessions;

  const FastingChart({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const Center(child: Text('Sem dados para o gráfico'));
    }

    final last7Days = sessions
        .where((s) =>
            s.endTime != null &&
            s.endTime!.isAfter(
              DateTime.now().subtract(const Duration(days: 7)),
            ))
        .toList();

    if (last7Days.isEmpty) {
      return const Center(child: Text('Sem dados para os últimos 7 dias'));
    }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxDuration(last7Days) + 1,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < last7Days.length) {
                    final date = last7Days[value.toInt()].startTime;
                    final day = DateFormat('E', 'pt_BR').format(date);
                    return Text(day);
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text('${value.toInt()}h');
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
          barGroups: _buildBarGroups(last7Days),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(List<FastingSessionEntity> sessions) {
    List<BarChartGroupData> groups = [];
    for (int i = 0; i < sessions.length; i++) {
      final session = sessions[i];
      final duration = session.endTime != null
          ? session.endTime!.difference(session.startTime)
          : Duration.zero;
      final hours = duration.inHours.toDouble();

      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: hours,
              color: Colors.green,
              width: 20,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }
    return groups;
  }

  double _getMaxDuration(List<FastingSessionEntity> sessions) {
    double maxHours = 0;
    for (var session in sessions) {
      if (session.endTime != null) {
        final hours =
            session.endTime!.difference(session.startTime).inHours.toDouble();
        if (hours > maxHours) maxHours = hours;
      }
    }
    return maxHours;
  }
}

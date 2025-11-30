import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/sensor_provider.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sensor = context.watch<SensorProvider>();
    final history = sensor.history;

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: history.isEmpty
          ? const Center(child: Text('Sem dados ainda.'))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: history.asMap().entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value.soilMoisture))
                          .toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: history.asMap().entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value.lightLevel))
                          .toList(),
                      isCurved: true,
                      color: Colors.amber,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                  minY: 0,
                  maxY: 100,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Últimos registros', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ...history.reversed.take(10).map((r) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Text('• '),
                          Expanded(
                            child: Text(
                              'Umidade ${r.soilMoisture.toStringAsFixed(0)}%  |  Luz ${r.lightLevel.toStringAsFixed(0)}%',
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

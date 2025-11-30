import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sensor_provider.dart';
import '../widgets/metric_card.dart';
import '../widgets/status_chip.dart';
import 'history_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final sensor = context.watch<SensorProvider>();
    final scheme = Theme.of(context).colorScheme;

    final moisture = sensor.reading.soilMoisture;
    final light = sensor.reading.lightLevel;

    final moistureOk = moisture >= sensor.moistureLow && moisture <= sensor.moistureHigh;
    final lightOk = light >= sensor.lightLow && light <= sensor.lightHigh;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PlantCare'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryPage()),
            ),
            tooltip: 'Histórico',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Header(emoji: sensor.emoji, status: sensor.statusText),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusChip(
                  label: moistureOk ? 'Umidade OK' : 'Baixa/Muito alta',
                  icon: Icons.water_drop,
                  color: moistureOk ? scheme.primary : Colors.orange,
                ),
                StatusChip(
                  label: lightOk ? 'Luz OK' : 'Pouca/Muita luz',
                  icon: Icons.wb_sunny,
                  color: lightOk ? scheme.primary : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),
            MetricCard(
              title: 'Umidade do solo',
              value: moisture,
              unitEmoji: '💧',
              color: scheme.primary,
              hint: moistureOk ? 'Faixa ideal' : (moisture < sensor.moistureLow ? 'Precisa regar' : 'Solo encharcado'),
            ),
            MetricCard(
              title: 'Luminosidade',
              value: light,
              unitEmoji: '☀️',
              color: Colors.amber.shade700,
              hint: lightOk ? 'Faixa ideal' : (light < sensor.lightLow ? 'Mais luz' : 'Luz demais'),
            ),
            const SizedBox(height: 16),
            Text('Controles remotos', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => sensor.togglePump(),
                  icon: Icon(sensor.pumpOn ? Icons.water_drop : Icons.water_drop_outlined),
                  label: Text(sensor.pumpOn ? 'Bomba ON' : 'Bomba OFF'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: sensor.pumpOn ? Colors.blue : Colors.grey.shade300,
                      foregroundColor: sensor.pumpOn ? Colors.white : Colors.black87,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => sensor.toggleLamp(),
                  icon: Icon(sensor.lampOn ? Icons.lightbulb : Icons.lightbulb_outline),
                  label: Text(sensor.lampOn ? 'Lâmpada ON' : 'Lâmpada OFF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sensor.lampOn ? Colors.amber : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Recommendations(items: sensor.recommendations),
            const SizedBox(height: 24),
            _Footer(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String emoji;
  final String status;

  const _Header({required this.emoji, required this.status});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              status,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _Recommendations extends StatelessWidget {
  final List<String> items;

  const _Recommendations({required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cuidados recomendados', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...items.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Text('• ', style: TextStyle(fontSize: 18)),
                  Expanded(child: Text(e)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.eco, color: scheme.primary),
        const SizedBox(width: 8),
        Text('Plantas em Cuidado', style: TextStyle(color: scheme.primary)),
      ],
    );
  }
}

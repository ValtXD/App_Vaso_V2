import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final double value; // 0–100
  final String unitEmoji;
  final Color color;
  final String hint;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unitEmoji,
    required this.color,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Text(unitEmoji, style: const TextStyle(fontSize: 20)),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: value / 100.0,
              minHeight: 10,
              color: color,
              backgroundColor: scheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('${value.toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                Text(hint, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

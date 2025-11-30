class SensorReading {
  final double soilMoisture; // 0–100 (%)
  final double lightLevel;   // 0–100 (% simulados)

  SensorReading({
    required this.soilMoisture,
    required this.lightLevel,
  });

  SensorReading copyWith({double? soilMoisture, double? lightLevel}) {
    return SensorReading(
      soilMoisture: soilMoisture ?? this.soilMoisture,
      lightLevel: lightLevel ?? this.lightLevel,
    );
  }

  Map<String, dynamic> toJson() => {
    'moisture': soilMoisture,
    'light': lightLevel,
  };

  factory SensorReading.fromJson(Map<String, dynamic> json) => SensorReading(
    soilMoisture: (json['moisture'] as num).toDouble(),
    lightLevel: (json['light'] as num).toDouble(),
  );
}

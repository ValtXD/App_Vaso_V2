import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sensor_reading.dart';

class SensorServiceHttp {
  final String baseUrl; // ex: http://192.168.0.50
  final _controller = StreamController<SensorReading>.broadcast();
  Timer? _poller;

  bool pumpOn = false;
  bool lampOn = false;
  bool autoMode = true;

  SensorServiceHttp(this.baseUrl);

  Stream<SensorReading> get readings => _controller.stream;

  Future<void> start() async {
    _poller = Timer.periodic(const Duration(seconds: 3), (_) async {
      try {
        final resp = await http.get(Uri.parse('$baseUrl/status')).timeout(const Duration(seconds: 2));
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body) as Map<String, dynamic>;
          final reading = SensorReading(
            soilMoisture: (data['soilMoisture'] as num).toDouble(),
            lightLevel: (data['lightLevel'] as num).toDouble(),
          );
          pumpOn = (data['pumpOn'] as bool? ?? false);
          lampOn = (data['lampOn'] as bool? ?? false);
          autoMode = (data['autoMode'] as bool? ?? true);
          _controller.add(reading);
        }
      } catch (_) {
        // silencioso: pode adicionar um estado de erro se quiser
      }
    });
  }

  Future<void> stop() async {
    _poller?.cancel();
    _poller = null;
  }

  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }

  Future<void> setPump(bool on) async {
    final url = Uri.parse('$baseUrl/pump?state=${on ? 'on' : 'off'}');
    await http.post(url);
    pumpOn = on;
  }

  Future<void> setLamp(bool on) async {
    final url = Uri.parse('$baseUrl/lamp?state=${on ? 'on' : 'off'}');
    await http.post(url);
    lampOn = on;
  }

  Future<void> setAutoMode(bool enable) async {
    final url = Uri.parse('$baseUrl/mode?auto=${enable ? 'true' : 'false'}');
    await http.post(url);
    autoMode = enable;
  }
}

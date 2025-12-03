import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/sensor_reading.dart';
import '../services/sensor_service_http.dart';

enum PlantMood { happy, neutral, sad }

class SensorProvider extends ChangeNotifier {
  // Troque pelo IP do ESP32 mostrado no Serial Monitor
  final SensorServiceHttp _service = SensorServiceHttp('http://192.168.0.50');

  SensorReading _reading = SensorReading(soilMoisture: 50, lightLevel: 50);
  PlantMood _mood = PlantMood.neutral;

  final double moistureLow = 35;
  final double moistureHigh = 70;
  final double lightLow = 40;
  final double lightHigh = 80;

  final List<SensorReading> _history = [];
  List<SensorReading> get history => List.unmodifiable(_history);

  bool get pumpOn => _service.pumpOn;
  bool get lampOn => _service.lampOn;
  bool get autoMode => _service.autoMode;

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  DateTime? _lastAlert;
  DateTime? _lastSaved;

  SensorReading get reading => _reading;
  PlantMood get mood => _mood;

  String get emoji {
    switch (_mood) {
      case PlantMood.happy:
        return '🌿😀';
      case PlantMood.neutral:
        return '🌱🙂';
      case PlantMood.sad:
        return '🥀😟';
    }
  }

  String get statusText {
    final moistureOk = _reading.soilMoisture >= moistureLow && _reading.soilMoisture <= moistureHigh;
    final lightOk = _reading.lightLevel >= lightLow && _reading.lightLevel <= lightHigh;

    if (moistureOk && lightOk) return 'Sua planta está feliz!';
    if (_reading.soilMoisture > moistureHigh && _reading.lightLevel > lightHigh) return 'Solo encharcado e luz demais.';
    if (_reading.soilMoisture > moistureHigh) return 'Solo muito úmido.';
    if (_reading.lightLevel > lightHigh) return 'Luz excessiva.';
    if (!moistureOk && !lightOk) return 'Precisa de água e luz.';
    if (!moistureOk) return 'Precisa regar.';
    return 'Precisa de mais luz.';
  }

  List<String> get recommendations {
    final rec = <String>[];
    if (_reading.soilMoisture < moistureLow) {
      rec.add('Regue um pouco 💧');
    } else if (_reading.soilMoisture > moistureHigh) {
      rec.add('Solo muito úmido — reduza a rega.');
    }
    if (_reading.lightLevel < lightLow) {
      rec.add('Leve para um local mais iluminado ☀️');
    } else if (_reading.lightLevel > lightHigh) {
      rec.add('Luz excessiva — sombra parcial pode ajudar.');
    }
    if (rec.isEmpty) {
      rec.add('Mantenha a rotina, está tudo bem 🌿');
    }
    return rec;
  }

  void _evaluateMood() {
    final moistureOk = _reading.soilMoisture >= moistureLow && _reading.soilMoisture <= moistureHigh;
    final lightOk = _reading.lightLevel >= lightLow && _reading.lightLevel <= lightHigh;

    if (moistureOk && lightOk) {
      _mood = PlantMood.happy;
    } else if (!moistureOk && !lightOk) {
      _mood = PlantMood.sad;
    } else {
      _mood = PlantMood.neutral;
    }
  }

  Future<void> initNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    await _notifications.initialize(initSettings);
  }

  void _checkNotifications() {
    final now = DateTime.now();
    final canAlert = _lastAlert == null || now.difference(_lastAlert!).inMinutes >= 10;

    final needsWater = _reading.soilMoisture < moistureLow;
    final needsLight = _reading.lightLevel < lightLow;
    final tooWet = _reading.soilMoisture > moistureHigh;
    final tooBright = _reading.lightLevel > lightHigh;

    if (!canAlert) return;

    String? msg;
    if (needsWater && needsLight) {
      msg = 'Sua planta precisa de água e luz 💧☀️';
    } else if (needsWater) {
      msg = 'Sua planta precisa de água 💧';
    } else if (needsLight) {
      msg = 'Sua planta precisa de mais luz ☀️';
    } else if (tooWet) {
      msg = 'Solo muito úmido — reduza a rega.';
    } else if (tooBright) {
      msg = 'Luz excessiva — dê sombra parcial.';
    }

    if (msg != null) {
      _showNotification(msg);
      _lastAlert = now;
    }
  }

  Future<void> _showNotification(String msg) async {
    const androidDetails = AndroidNotificationDetails(
      'plantcare_channel',
      'PlantCare Alerts',
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _notifications.show(0, 'PlantCare', msg, details);
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = _history.map((r) => {
      'moisture': r.soilMoisture,
      'light': r.lightLevel,
    }).toList();
    await prefs.setString('history', jsonEncode(payload));
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('history');
    if (data != null) {
      final list = jsonDecode(data) as List;
      _history
        ..clear()
        ..addAll(list.map((e) => SensorReading(
          soilMoisture: (e['moisture'] as num).toDouble(),
          lightLevel: (e['light'] as num).toDouble(),
        )));
      notifyListeners();
    }
  }

  void _saveHistoryIfNeeded() async {
    final now = DateTime.now();
    if (_lastSaved == null || now.difference(_lastSaved!).inMinutes >= 5) {
      _history.add(_reading);
      if (_history.length > 200) _history.removeAt(0);
      await _saveHistory();
      _lastSaved = now;
    }
  }

  Future<void> start() async {
    await _loadHistory();
    await _service.start();
    _service.readings.listen((r) {
      _reading = r;
      _evaluateMood();
      _saveHistoryIfNeeded();
      _checkNotifications();
      notifyListeners();
    });
  }

  Future<void> togglePump() async {
    final next = !pumpOn;
    await _service.setPump(next);
    notifyListeners();
  }

  Future<void> toggleLamp() async {
    final next = !lampOn;
    await _service.setLamp(next);
    notifyListeners();
  }

  Future<void> setAuto(bool enable) async {
    await _service.setAutoMode(enable);
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}

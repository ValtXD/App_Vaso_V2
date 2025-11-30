import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'providers/sensor_provider.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final provider = SensorProvider();
  await provider.initNotifications();
  provider.start();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => provider),
      ],
      child: const PlantCareApp(),
    ),
  );
}

class PlantCareApp extends StatelessWidget {
  const PlantCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlantCare',
      debugShowCheckedModeBanner: false,
      theme: PlantTheme.light,
      home: const HomePage(),
    );
  }
}

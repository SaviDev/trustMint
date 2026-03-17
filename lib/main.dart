import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/home/home_screen.dart';
import 'background/background_entrypoint.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise the Foreground Service — this must be done before runApp.
  // The FGS will automatically start in the background with autoStart: true.
  await initBackgroundService();

  runApp(const ProviderScope(child: DataCollectionApp()));
}

class DataCollectionApp extends StatelessWidget {
  const DataCollectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Data Collector',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF6C63FF),
          surface: const Color(0xFF1A1D2E),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import '../../data/local/database/app_database.dart';
import '../../data/local/secure_storage.dart';

class EmaScreen extends StatelessWidget {
  final String emaId;
  const EmaScreen({super.key, required this.emaId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        title: const Text('Daily Mood 📝', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A1D2E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'How are you feeling right now?',
                style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _MoodEmoji(emoji: '😢', label: 'Sad', color: Colors.blueAccent, 
                    onTap: () => _submit(context, 'sad')),
                  _MoodEmoji(emoji: '😐', label: 'Neutral', color: Colors.grey, 
                    onTap: () => _submit(context, 'neutral')),
                  _MoodEmoji(emoji: '😊', label: 'Happy', color: Colors.green, 
                    onTap: () => _submit(context, 'happy')),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _submit(BuildContext context, String mood) async {
    final storage = SecureStorage();
    final userId = await storage.getUserId() ?? 'unknown';
    
    await dbInstance.sensorDao.insertBatch([
      SensorDataTableCompanion.insert(
        bandoId: drift.Value(emaId),
        userId: userId,
        sessionId: 'ema-\${DateTime.now().millisecondsSinceEpoch}',
        sensorType: 'mood_survey',
        value: jsonEncode({'mood': mood}),
        timestamp: DateTime.now(),
      )
    ]);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Answer saved successfully. Thank you!'), backgroundColor: Color(0xFF2ECC71)),
    );
    Navigator.of(context).pop();
  }
}

class _MoodEmoji extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MoodEmoji({required this.emoji, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

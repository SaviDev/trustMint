import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/bando.dart';
import '../../domain/entities/ema_config.dart';

class BandiState {
  final List<Bando> available;
  final List<Bando> myBandi;

  BandiState({required this.available, required this.myBandi});

  BandiState copyWith({List<Bando>? available, List<Bando>? myBandi}) {
    return BandiState(
      available: available ?? this.available,
      myBandi: myBandi ?? this.myBandi,
    );
  }
}

class BandiController extends StateNotifier<BandiState> {
  BandiController()
      : super(BandiState(
          available: [
            Bando(
              id: 'b1',
              title: 'Daily Sensors Activity',
              description: 'Collects phone sensor data continuously in the background throughout the day.',
              durationDays: 30,
              payout: 50.0,
              requiredSensors: [],
            ),
            Bando(
              id: 'b2',
              title: 'Daily Mood',
              description: 'Periodic psychological survey: you will receive a notification every 2 minutes to evaluate your mood.',
              durationDays: 14,
              payout: 25.0,
              requiredSensors: [],
              emaConfig: EmaConfig(
                id: 'mood_survey',
                scheduleTimes: [],
                questions: [],
              ), // Marca il Bando come Survey/EMA
            ),
          ],
          myBandi: [],
        ));

  void participate(Bando bando) {
    if (state.myBandi.any((b) => b.id == bando.id)) return;
    
    final newMyBandi = [...state.myBandi, bando];

    state = state.copyWith(myBandi: newMyBandi);
  }
}

final bandiProvider = StateNotifierProvider<BandiController, BandiState>((ref) {
  return BandiController();
});

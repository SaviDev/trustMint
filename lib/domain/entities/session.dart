enum SessionStatus { running, paused, stopped }

class Session {
  final String id;
  final String bandoId;
  final DateTime startTime;
  final SessionStatus status;

  Session({
    required this.id,
    required this.bandoId,
    required this.startTime,
    required this.status,
  });
}

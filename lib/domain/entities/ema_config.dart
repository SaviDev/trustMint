class EmaConfig {
  final String id;
  final List<String> scheduleTimes; // e.g. ['09:00', '18:00']
  final List<EmaQuestion> questions;

  EmaConfig({required this.id, required this.scheduleTimes, required this.questions});
}

class EmaQuestion {
  final String id;
  final String text;
  final String type; // 'slider', 'multi-choice', 'text'

  EmaQuestion({required this.id, required this.text, required this.type});
}

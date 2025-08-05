// lib/src/data/models/emotion_log_model.dart

enum Emotion { happy, sad, anxious, calm, frustrated, excited }

class EmotionLog {
  final String id;
  final Emotion emotion;
  final DateTime timestamp;
  final String? note;

  EmotionLog({
    required this.id,
    required this.emotion,
    required this.timestamp,
    this.note,
  });

  // From JSON
  factory EmotionLog.fromJson(Map<String, dynamic> json) {
    return EmotionLog(
      id: json['id'] as String,
      emotion: Emotion.values.firstWhere(
            (e) => e.toString().split('.').last == json['emotion'],
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      note: json['note'] as String?,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emotion': emotion.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }
}
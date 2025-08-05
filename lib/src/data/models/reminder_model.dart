// lib/src/data/models/reminder_model.dart

class Reminder {
  final String id;
  final String title;
  final String? description;
  final DateTime dateTime;
  bool isCompleted;

  Reminder({
    required this.id,
    required this.title,
    this.description,
    required this.dateTime,
    this.isCompleted = false,
  });

  // From JSON
  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      dateTime: DateTime.parse(json['dateTime'] as String),
      isCompleted: json['isCompleted'] as bool,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    bool? isCompleted,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

// Mock Data
final List<Reminder> MOCK_REMINDERS = [
  Reminder(id: '1', title: 'Take morning medication', dateTime: DateTime.now(), isCompleted: false),
  Reminder(id: '2', title: 'Call family member', dateTime: DateTime.now().add(const Duration(hours: 1)), isCompleted: false),
  Reminder(id: '3', title: 'Drink water', dateTime: DateTime.now().add(const Duration(hours: 2)), isCompleted: false),
];
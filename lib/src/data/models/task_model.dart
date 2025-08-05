// lib/src/data/models/task_model.dart

enum TaskPriority { low, medium, high }

class Task {
  final String id;
  final String title;
  bool completed;
  final DateTime? dueDate;
  final TaskPriority? priority;

  Task({
    required this.id,
    required this.title,
    this.completed = false,
    this.dueDate,
    this.priority,
  });

  // From JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      completed: json['completed'] as bool,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      priority: json['priority'] != null ? TaskPriority.values.firstWhere(
            (e) => e.toString().split('.').last == json['priority'],
      ) : null,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority?.toString().split('.').last,
    };
  }

  Task copyWith({
    String? id,
    String? title,
    bool? completed,
    DateTime? dueDate,
    TaskPriority? priority,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
    );
  }
}

// Mock Data
final List<Task> MOCK_TASKS = [
  Task(id: '1', title: 'Take medication', completed: false, priority: TaskPriority.high),
  Task(id: '2', title: 'Doctor appointment', completed: true, priority: TaskPriority.medium),
  Task(id: '3', title: 'Drink water', completed: false, priority: TaskPriority.low),
  Task(id: '4', title: 'Exercise for 15 minutes', completed: false, priority: TaskPriority.medium),
];
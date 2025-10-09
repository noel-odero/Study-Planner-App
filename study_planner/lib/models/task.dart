class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final DateTime? reminderDateTime;
  final bool done;
  final bool reminderShown;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    this.reminderDateTime,
    this.done = false,
    this.reminderShown = false,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    DateTime? reminderDateTime,
    bool? done,
    bool? reminderShown,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      reminderDateTime: reminderDateTime ?? this.reminderDateTime,
      done: done ?? this.done,
      reminderShown: reminderShown ?? this.reminderShown,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'reminderDateTime': reminderDateTime?.toIso8601String(),
      'done': done ? 1 : 0,
      'reminderShown': reminderShown ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> m) {
    return Task(
      id: m['id'] as String,
      title: m['title'] as String,
      description: m['description'] as String?,
      dueDate: DateTime.parse(m['dueDate'] as String),
      reminderDateTime: m['reminderDateTime'] != null
          ? DateTime.parse(m['reminderDateTime'] as String)
          : null,
      done: (m['done'] ?? 0) == 1,
      reminderShown: (m['reminderShown'] ?? 0) == 1,
    );
  }
}

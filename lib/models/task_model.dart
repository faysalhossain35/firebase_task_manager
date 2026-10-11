enum TaskPriority { low, medium, high }

enum TaskFilter { all, pending, completed }

class TaskModel {
  static int _idCounter = 0;

  TaskModel({
    String? id,
    required this.title,
    required this.notes,
    required this.dueDate,
    required this.priority,
    this.isDone = false,
  }) : id = id ?? _generateId();

  static String _generateId() {
    final stamp = DateTime.now().microsecondsSinceEpoch;
    _idCounter += 1;
    return 'task_${stamp}_${_idCounter.toString().padLeft(6, '0')}';
  }

  final String id;
  final String title;
  final String notes;
  final DateTime dueDate;
  final TaskPriority priority;
  final bool isDone;

  TaskModel copyWith({
    String? id,
    String? title,
    String? notes,
    DateTime? dueDate,
    TaskPriority? priority,
    bool? isDone,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isDone: isDone ?? this.isDone,
    );
  }

  String get priorityLabel {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  String get dueDateText =>
      '${dueDate.month.toString().padLeft(2, '0')}/${dueDate.day.toString().padLeft(2, '0')}/${dueDate.year}';
}

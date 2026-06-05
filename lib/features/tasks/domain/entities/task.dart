import 'package:equatable/equatable.dart';

enum TaskStatus {
  pending,
  inProgress,
  completed;

  String get apiValue {
    switch (this) {
      case TaskStatus.pending:
        return 'pending';
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.completed:
        return 'completed';
    }
  }

  String get label {
    switch (this) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
    }
  }

  static TaskStatus fromApi(String? value) {
    switch (value) {
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'completed':
        return TaskStatus.completed;
      case 'pending':
      default:
        return TaskStatus.pending;
    }
  }
}

enum TaskPriority {
  low,
  medium,
  high;

  String get apiValue => name;

  String get label => '${name[0].toUpperCase()}${name.substring(1)}';

  static TaskPriority fromApi(String? value) {
    switch (value) {
      case 'high':
        return TaskPriority.high;
      case 'low':
        return TaskPriority.low;
      case 'medium':
      default:
        return TaskPriority.medium;
    }
  }
}

class Task extends Equatable {
  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.dueDate,
  });

  final int id;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? dueDate;

  Task copyWith({TaskStatus? status}) {
    return Task(
      id: id,
      title: title,
      description: description,
      status: status ?? this.status,
      priority: priority,
      dueDate: dueDate,
    );
  }

  @override
  List<Object?> get props => [id, title, description, status, priority, dueDate];
}

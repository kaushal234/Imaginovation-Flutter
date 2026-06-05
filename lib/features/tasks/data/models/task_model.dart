import 'package:imaginovation_app/features/tasks/domain/entities/task.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.title,
    super.description,
    required super.status,
    required super.priority,
    super.dueDate,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final due = json['due_date']?.toString();
    return TaskModel(
      id: (json['id'] as num).toInt(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      status: TaskStatus.fromApi(json['status']?.toString()),
      priority: TaskPriority.fromApi(json['priority']?.toString()),
      dueDate: (due != null && due.isNotEmpty) ? DateTime.tryParse(due) : null,
    );
  }
}

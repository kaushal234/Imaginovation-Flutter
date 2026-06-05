part of 'task_form_bloc.dart';

sealed class TaskFormEvent extends Equatable {
  const TaskFormEvent();

  @override
  List<Object?> get props => [];
}

class TaskFormSubmitted extends TaskFormEvent {
  const TaskFormSubmitted({
    this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    required this.dueDate,
  });

  final int? id;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime dueDate;

  @override
  List<Object?> get props => [id, title, description, status, priority, dueDate];
}

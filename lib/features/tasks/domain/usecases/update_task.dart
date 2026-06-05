import 'package:dartz/dartz.dart' show Either;
import 'package:equatable/equatable.dart';

import 'package:imaginovation_app/core/error/failures.dart';
import 'package:imaginovation_app/core/usecase/usecase.dart';
import 'package:imaginovation_app/features/tasks/domain/entities/task.dart';
import 'package:imaginovation_app/features/tasks/domain/repositories/task_repository.dart';

class UpdateTask implements UseCase<Task, UpdateTaskParams> {
  UpdateTask(this._repository);

  final TaskRepository _repository;

  @override
  Future<Either<Failure, Task>> call(UpdateTaskParams params) {
    return _repository.updateTask(
      params.id,
      title: params.title,
      description: params.description,
      status: params.status,
      priority: params.priority,
      dueDate: params.dueDate,
    );
  }
}

class UpdateTaskParams extends Equatable {
  const UpdateTaskParams({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    required this.dueDate,
  });

  final int id;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime dueDate;

  @override
  List<Object?> get props =>
      [id, title, description, status, priority, dueDate];
}

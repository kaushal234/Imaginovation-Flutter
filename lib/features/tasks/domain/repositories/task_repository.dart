import 'package:dartz/dartz.dart' show Either, Unit;

import 'package:imaginovation_app/core/error/failures.dart';
import 'package:imaginovation_app/features/tasks/domain/entities/paginated_tasks.dart';
import 'package:imaginovation_app/features/tasks/domain/entities/task.dart';

abstract class TaskRepository {
  Future<Either<Failure, PaginatedTasks>> getTasks({
    int page,
    int perPage,
    String? status,
    String? priority,
    String? search,
  });

  Future<Either<Failure, Task>> getTask(int id);

  Future<Either<Failure, Task>> createTask({
    required String title,
    String? description,
    required TaskStatus status,
    required TaskPriority priority,
    required DateTime dueDate,
  });

  Future<Either<Failure, Task>> updateTask(
    int id, {
    required String title,
    String? description,
    required TaskStatus status,
    required TaskPriority priority,
    required DateTime dueDate,
  });

  Future<Either<Failure, Task>> updateTaskStatus(int id, TaskStatus status);

  Future<Either<Failure, Unit>> deleteTask(int id);
}

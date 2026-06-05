import 'package:dartz/dartz.dart' show Either, Left, Right, Unit, unit;

import 'package:imaginovation_app/core/error/exceptions.dart';
import 'package:imaginovation_app/core/error/failures.dart';
import 'package:imaginovation_app/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:imaginovation_app/features/tasks/domain/entities/paginated_tasks.dart';
import 'package:imaginovation_app/features/tasks/domain/entities/task.dart';
import 'package:imaginovation_app/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._remote);

  final TaskRemoteDataSource _remote;

  @override
  Future<Either<Failure, PaginatedTasks>> getTasks({
    int page = 1,
    int perPage = 10,
    String? status,
    String? priority,
    String? search,
  }) async {
    try {
      final result = await _remote.getTasks(
        page: page,
        perPage: perPage,
        status: status,
        priority: priority,
        search: search,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, Task>> getTask(int id) async {
    try {
      return Right(await _remote.getTask(id));
    } on ServerException catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, Task>> createTask({
    required String title,
    String? description,
    required TaskStatus status,
    required TaskPriority priority,
    required DateTime dueDate,
  }) async {
    try {
      final task = await _remote.createTask(
        title: title,
        description: description,
        status: status,
        priority: priority,
        dueDate: dueDate,
      );
      return Right(task);
    } on ServerException catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, Task>> updateTask(
    int id, {
    required String title,
    String? description,
    required TaskStatus status,
    required TaskPriority priority,
    required DateTime dueDate,
  }) async {
    try {
      final task = await _remote.updateTask(
        id,
        title: title,
        description: description,
        status: status,
        priority: priority,
        dueDate: dueDate,
      );
      return Right(task);
    } on ServerException catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, Task>> updateTaskStatus(
    int id,
    TaskStatus status,
  ) async {
    try {
      return Right(await _remote.updateTaskStatus(id, status));
    } on ServerException catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTask(int id) async {
    try {
      await _remote.deleteTask(id);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(_mapException(e));
    }
  }

  Failure _mapException(ServerException e) {
    if (e.statusCode == 422) {
      return ValidationFailure(e.message, errors: e.errors);
    }
    return ServerFailure(e.message, statusCode: e.statusCode);
  }
}

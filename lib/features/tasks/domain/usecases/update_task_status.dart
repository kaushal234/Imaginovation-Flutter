import 'package:dartz/dartz.dart' show Either;
import 'package:equatable/equatable.dart';

import 'package:imaginovation_app/core/error/failures.dart';
import 'package:imaginovation_app/core/usecase/usecase.dart';
import 'package:imaginovation_app/features/tasks/domain/entities/task.dart';
import 'package:imaginovation_app/features/tasks/domain/repositories/task_repository.dart';

class UpdateTaskStatus implements UseCase<Task, UpdateTaskStatusParams> {
  UpdateTaskStatus(this._repository);

  final TaskRepository _repository;

  @override
  Future<Either<Failure, Task>> call(UpdateTaskStatusParams params) =>
      _repository.updateTaskStatus(params.id, params.status);
}

class UpdateTaskStatusParams extends Equatable {
  const UpdateTaskStatusParams({required this.id, required this.status});

  final int id;
  final TaskStatus status;

  @override
  List<Object?> get props => [id, status];
}

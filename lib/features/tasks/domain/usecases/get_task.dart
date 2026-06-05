import 'package:dartz/dartz.dart' show Either;
import 'package:equatable/equatable.dart';

import 'package:imaginovation_app/core/error/failures.dart';
import 'package:imaginovation_app/core/usecase/usecase.dart';
import 'package:imaginovation_app/features/tasks/domain/entities/task.dart';
import 'package:imaginovation_app/features/tasks/domain/repositories/task_repository.dart';

class GetTask implements UseCase<Task, GetTaskParams> {
  GetTask(this._repository);

  final TaskRepository _repository;

  @override
  Future<Either<Failure, Task>> call(GetTaskParams params) =>
      _repository.getTask(params.id);
}

class GetTaskParams extends Equatable {
  const GetTaskParams(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

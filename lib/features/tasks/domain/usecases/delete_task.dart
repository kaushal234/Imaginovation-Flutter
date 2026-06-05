import 'package:dartz/dartz.dart' show Either, Unit;
import 'package:equatable/equatable.dart';

import 'package:imaginovation_app/core/error/failures.dart';
import 'package:imaginovation_app/core/usecase/usecase.dart';
import 'package:imaginovation_app/features/tasks/domain/repositories/task_repository.dart';

class DeleteTask implements UseCase<Unit, DeleteTaskParams> {
  DeleteTask(this._repository);

  final TaskRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(DeleteTaskParams params) =>
      _repository.deleteTask(params.id);
}

class DeleteTaskParams extends Equatable {
  const DeleteTaskParams(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

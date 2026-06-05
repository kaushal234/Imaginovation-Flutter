import 'package:dartz/dartz.dart' show Either;
import 'package:equatable/equatable.dart';

import 'package:imaginovation_app/core/error/failures.dart';
import 'package:imaginovation_app/core/usecase/usecase.dart';
import 'package:imaginovation_app/features/tasks/domain/entities/paginated_tasks.dart';
import 'package:imaginovation_app/features/tasks/domain/repositories/task_repository.dart';

class GetTasks implements UseCase<PaginatedTasks, GetTasksParams> {
  GetTasks(this._repository);

  final TaskRepository _repository;

  @override
  Future<Either<Failure, PaginatedTasks>> call(GetTasksParams params) {
    return _repository.getTasks(
      page: params.page,
      perPage: params.perPage,
      status: params.status,
      priority: params.priority,
      search: params.search,
    );
  }
}

class GetTasksParams extends Equatable {
  const GetTasksParams({
    this.page = 1,
    this.perPage = 10,
    this.status,
    this.priority,
    this.search,
  });

  final int page;
  final int perPage;
  final String? status;
  final String? priority;
  final String? search;

  @override
  List<Object?> get props => [page, perPage, status, priority, search];
}

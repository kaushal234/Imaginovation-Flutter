import 'package:equatable/equatable.dart';

import 'package:imaginovation_app/features/tasks/domain/entities/task.dart';

class PaginatedTasks extends Equatable {
  const PaginatedTasks({
    required this.tasks,
    required this.currentPage,
    required this.lastPage,
  });

  final List<Task> tasks;
  final int currentPage;
  final int lastPage;

  bool get hasMore => currentPage < lastPage;

  @override
  List<Object?> get props => [tasks, currentPage, lastPage];
}

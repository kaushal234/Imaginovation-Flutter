part of 'task_list_bloc.dart';

sealed class TaskListEvent extends Equatable {
  const TaskListEvent();

  @override
  List<Object?> get props => [];
}

class TaskListStarted extends TaskListEvent {
  const TaskListStarted();
}

class TaskListRefreshed extends TaskListEvent {
  const TaskListRefreshed();
}

class TaskListLoadMore extends TaskListEvent {
  const TaskListLoadMore();
}

class TaskListFiltersChanged extends TaskListEvent {
  const TaskListFiltersChanged({this.status, this.priority, this.search});

  final String? status;
  final String? priority;
  final String? search;

  @override
  List<Object?> get props => [status, priority, search];
}

class TaskListItemCompleted extends TaskListEvent {
  const TaskListItemCompleted(this.task);

  final Task task;

  @override
  List<Object?> get props => [task];
}

class TaskListItemDeleted extends TaskListEvent {
  const TaskListItemDeleted(this.task);

  final Task task;

  @override
  List<Object?> get props => [task];
}

part of 'task_list_bloc.dart';

enum TaskListStatus { initial, loading, success, failure }

class TaskListState extends Equatable {
  const TaskListState({
    this.status = TaskListStatus.initial,
    this.tasks = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final TaskListStatus status;
  final List<Task> tasks;
  final int currentPage;
  final int lastPage;
  final bool isLoadingMore;
  final String? errorMessage;

  bool get hasMore => currentPage < lastPage;

  TaskListState copyWith({
    TaskListStatus? status,
    List<Task>? tasks,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TaskListState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [status, tasks, currentPage, lastPage, isLoadingMore, errorMessage];
}

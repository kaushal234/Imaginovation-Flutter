part of 'task_detail_bloc.dart';

enum TaskDetailStatus { loading, loaded, failure }

class TaskDetailState extends Equatable {
  const TaskDetailState({
    this.status = TaskDetailStatus.loading,
    this.task,
    this.errorMessage,
  });

  final TaskDetailStatus status;
  final Task? task;
  final String? errorMessage;

  TaskDetailState copyWith({
    TaskDetailStatus? status,
    Task? task,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TaskDetailState(
      status: status ?? this.status,
      task: task ?? this.task,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, task, errorMessage];
}

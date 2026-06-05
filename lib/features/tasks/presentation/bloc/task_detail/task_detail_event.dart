part of 'task_detail_bloc.dart';

sealed class TaskDetailEvent extends Equatable {
  const TaskDetailEvent();

  @override
  List<Object?> get props => [];
}

class TaskDetailRequested extends TaskDetailEvent {
  const TaskDetailRequested({required this.id, this.initialTask});

  final int id;
  final Task? initialTask;

  @override
  List<Object?> get props => [id, initialTask];
}

class TaskDetailStatusChanged extends TaskDetailEvent {
  const TaskDetailStatusChanged(this.status);

  final TaskStatus status;

  @override
  List<Object?> get props => [status];
}

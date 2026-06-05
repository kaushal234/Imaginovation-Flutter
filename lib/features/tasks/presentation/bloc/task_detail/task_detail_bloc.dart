import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:imaginovation_app/features/tasks/domain/entities/task.dart';
import 'package:imaginovation_app/features/tasks/domain/usecases/get_task.dart';
import 'package:imaginovation_app/features/tasks/domain/usecases/update_task_status.dart';

part 'task_detail_event.dart';
part 'task_detail_state.dart';

class TaskDetailBloc extends Bloc<TaskDetailEvent, TaskDetailState> {
  TaskDetailBloc({
    required GetTask getTask,
    required UpdateTaskStatus updateTaskStatus,
  })  : _getTask = getTask,
        _updateTaskStatus = updateTaskStatus,
        super(const TaskDetailState()) {
    on<TaskDetailRequested>(_onRequested);
    on<TaskDetailStatusChanged>(_onStatusChanged);
  }

  final GetTask _getTask;
  final UpdateTaskStatus _updateTaskStatus;

  Future<void> _onRequested(
    TaskDetailRequested event,
    Emitter<TaskDetailState> emit,
  ) async {
    if (event.initialTask != null) {
      emit(
        state.copyWith(
          status: TaskDetailStatus.loaded,
          task: event.initialTask,
        ),
      );
      return;
    }
    emit(state.copyWith(status: TaskDetailStatus.loading, clearError: true));
    final result = await _getTask(GetTaskParams(event.id));
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TaskDetailStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (task) =>
          emit(state.copyWith(status: TaskDetailStatus.loaded, task: task)),
    );
  }

  Future<void> _onStatusChanged(
    TaskDetailStatusChanged event,
    Emitter<TaskDetailState> emit,
  ) async {
    final current = state.task;
    if (current == null || current.status == event.status) return;

    // Optimistic update.
    emit(state.copyWith(task: current.copyWith(status: event.status)));

    final result = await _updateTaskStatus(
      UpdateTaskStatusParams(id: current.id, status: event.status),
    );
    result.fold(
      (failure) =>
          emit(state.copyWith(task: current, errorMessage: failure.message)),
      (updated) => emit(state.copyWith(task: updated)),
    );
  }
}

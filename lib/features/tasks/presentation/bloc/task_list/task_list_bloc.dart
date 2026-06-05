import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:imaginovation_app/features/tasks/domain/entities/task.dart';
import 'package:imaginovation_app/features/tasks/domain/usecases/delete_task.dart';
import 'package:imaginovation_app/features/tasks/domain/usecases/get_tasks.dart';
import 'package:imaginovation_app/features/tasks/domain/usecases/update_task_status.dart';

part 'task_list_event.dart';
part 'task_list_state.dart';

class TaskListBloc extends Bloc<TaskListEvent, TaskListState> {
  TaskListBloc({
    required GetTasks getTasks,
    required UpdateTaskStatus updateTaskStatus,
    required DeleteTask deleteTask,
  })  : _getTasks = getTasks,
        _updateTaskStatus = updateTaskStatus,
        _deleteTask = deleteTask,
        super(const TaskListState()) {
    on<TaskListStarted>(_onStarted);
    on<TaskListRefreshed>(_onStarted);
    on<TaskListFiltersChanged>(_onFiltersChanged);
    on<TaskListLoadMore>(_onLoadMore);
    on<TaskListItemCompleted>(_onItemCompleted);
    on<TaskListItemDeleted>(_onItemDeleted);
  }

  final GetTasks _getTasks;
  final UpdateTaskStatus _updateTaskStatus;
  final DeleteTask _deleteTask;

  String? _status;
  String? _priority;
  String? _search;

  Future<void> _onStarted(
    TaskListEvent event,
    Emitter<TaskListState> emit,
  ) async {
    emit(state.copyWith(status: TaskListStatus.loading, clearError: true));
    final result = await _getTasks(
      GetTasksParams(
        page: 1,
        status: _status,
        priority: _priority,
        search: _search,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TaskListStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (page) => emit(
        state.copyWith(
          status: TaskListStatus.success,
          tasks: page.tasks,
          currentPage: page.currentPage,
          lastPage: page.lastPage,
        ),
      ),
    );
  }

  Future<void> _onFiltersChanged(
    TaskListFiltersChanged event,
    Emitter<TaskListState> emit,
  ) async {
    _status = event.status;
    _priority = event.priority;
    _search = event.search;
    await _onStarted(event, emit);
  }

  Future<void> _onLoadMore(
    TaskListLoadMore event,
    Emitter<TaskListState> emit,
  ) async {
    if (state.isLoadingMore ||
        !state.hasMore ||
        state.status != TaskListStatus.success) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true));
    final result = await _getTasks(
      GetTasksParams(
        page: state.currentPage + 1,
        status: _status,
        priority: _priority,
        search: _search,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingMore: false, errorMessage: failure.message),
      ),
      (page) => emit(
        state.copyWith(
          tasks: [...state.tasks, ...page.tasks],
          currentPage: page.currentPage,
          lastPage: page.lastPage,
          isLoadingMore: false,
        ),
      ),
    );
  }

  Future<void> _onItemCompleted(
    TaskListItemCompleted event,
    Emitter<TaskListState> emit,
  ) async {
    final previous = state.tasks;
    final updated = previous
        .map((t) => t.id == event.task.id
            ? t.copyWith(status: TaskStatus.completed)
            : t)
        .toList();
    emit(state.copyWith(tasks: updated, clearError: true));

    final result = await _updateTaskStatus(
      UpdateTaskStatusParams(id: event.task.id, status: TaskStatus.completed),
    );
    result.fold(
      (failure) =>
          emit(state.copyWith(tasks: previous, errorMessage: failure.message)),
      (_) {},
    );
  }

  Future<void> _onItemDeleted(
    TaskListItemDeleted event,
    Emitter<TaskListState> emit,
  ) async {
    final previous = state.tasks;
    emit(
      state.copyWith(
        tasks: previous.where((t) => t.id != event.task.id).toList(),
        clearError: true,
      ),
    );

    final result = await _deleteTask(DeleteTaskParams(event.task.id));
    result.fold(
      (failure) =>
          emit(state.copyWith(tasks: previous, errorMessage: failure.message)),
      (_) {},
    );
  }
}

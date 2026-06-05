import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imaginovation_app/features/tasks/domain/entities/task.dart';
import 'package:imaginovation_app/features/tasks/domain/usecases/create_task.dart';
import 'package:imaginovation_app/features/tasks/domain/usecases/update_task.dart';

part 'task_form_event.dart';
part 'task_form_state.dart';

class TaskFormBloc extends Bloc<TaskFormEvent, TaskFormState> {
  TaskFormBloc({
    required CreateTask createTask,
    required UpdateTask updateTask,
  })  : _createTask = createTask,
        _updateTask = updateTask,
        super(const TaskFormState()) {
    on<TaskFormSubmitted>(_onSubmitted);
  }

  final CreateTask _createTask;
  final UpdateTask _updateTask;

  Future<void> _onSubmitted(
    TaskFormSubmitted event,
    Emitter<TaskFormState> emit,
  ) async {
    emit(const TaskFormState(status: TaskFormStatus.submitting));

    final result = event.id == null
        ? await _createTask(
            CreateTaskParams(
              title: event.title,
              description: event.description,
              status: event.status,
              priority: event.priority,
              dueDate: event.dueDate,
            ),
          )
        : await _updateTask(
            UpdateTaskParams(
              id: event.id!,
              title: event.title,
              description: event.description,
              status: event.status,
              priority: event.priority,
              dueDate: event.dueDate,
            ),
          );

    result.fold(
      (failure) => emit(
        TaskFormState(
          status: TaskFormStatus.failure,
          errorMessage: failure.firstError() ?? failure.message,
          fieldErrors: failure.errors,
        ),
      ),
      (_) => emit(const TaskFormState(status: TaskFormStatus.success)),
    );
  }
}

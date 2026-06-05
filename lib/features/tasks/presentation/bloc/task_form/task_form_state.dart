part of 'task_form_bloc.dart';

enum TaskFormStatus { initial, submitting, success, failure }

class TaskFormState extends Equatable {
  const TaskFormState({
    this.status = TaskFormStatus.initial,
    this.errorMessage,
    this.fieldErrors,
  });

  final TaskFormStatus status;
  final String? errorMessage;
  final Map<String, dynamic>? fieldErrors;

  @override
  List<Object?> get props => [status, errorMessage, fieldErrors];
}

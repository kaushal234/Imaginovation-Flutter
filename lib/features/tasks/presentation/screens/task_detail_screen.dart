import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:imaginovation_app/features/tasks/domain/entities/task.dart';
import 'package:imaginovation_app/features/tasks/presentation/bloc/task_detail/task_detail_bloc.dart';
import 'package:imaginovation_app/features/tasks/presentation/widgets/status_chip.dart';
import 'package:imaginovation_app/injection_container.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.taskId, this.initialTask});

  final int taskId;
  final Task? initialTask;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TaskDetailBloc>()
        ..add(TaskDetailRequested(id: taskId, initialTask: initialTask)),
      child: _TaskDetailView(taskId: taskId),
    );
  }
}

class _TaskDetailView extends StatelessWidget {
  const _TaskDetailView({required this.taskId});

  final int taskId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          BlocBuilder<TaskDetailBloc, TaskDetailState>(
            builder: (context, state) {
              final task = state.task;
              if (task == null) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final changed = await context
                      .push<bool>('/tasks/${task.id}/edit', extra: task);
                  if (changed == true && context.mounted) {
                    context
                        .read<TaskDetailBloc>()
                        .add(TaskDetailRequested(id: taskId));
                  }
                },
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<TaskDetailBloc, TaskDetailState>(
        listener: (context, state) {
          if (state.errorMessage != null &&
              state.status == TaskDetailStatus.loaded) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          if (state.status == TaskDetailStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final task = state.task;
          if (state.status == TaskDetailStatus.failure && task == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(state.errorMessage ?? 'Failed to load task',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => context
                          .read<TaskDetailBloc>()
                          .add(TaskDetailRequested(id: taskId)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (task == null) {
            return const Center(child: Text('Task not found.'));
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(task.title,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Row(
                children: [
                  PriorityChip(priority: task.priority),
                  const SizedBox(width: 8),
                  StatusChip(status: task.status),
                ],
              ),
              const SizedBox(height: 24),
              if (task.dueDate != null) ...[
                Row(
                  children: [
                    const Icon(Icons.event, size: 20, color: Colors.grey),
                    const SizedBox(width: 10),
                    const Text('Due date: ',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Expanded(
                      child: Text(
                        DateFormat('EEEE, MMM d, yyyy').format(task.dueDate!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              const Text('Description',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              Text(
                (task.description == null || task.description!.isEmpty)
                    ? 'No description provided.'
                    : task.description!,
                style: const TextStyle(height: 1.5),
              ),
              const SizedBox(height: 28),
              const Text('Update status',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: TaskStatus.values.map((s) {
                  return ChoiceChip(
                    label: Text(s.label),
                    selected: task.status == s,
                    onSelected: (_) => context
                        .read<TaskDetailBloc>()
                        .add(TaskDetailStatusChanged(s)),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

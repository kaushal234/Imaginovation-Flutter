import 'package:flutter/material.dart';

import 'package:imaginovation_app/features/tasks/domain/entities/task.dart';

Color statusColor(TaskStatus status) {
  switch (status) {
    case TaskStatus.pending:
      return Colors.blueGrey;
    case TaskStatus.inProgress:
      return Colors.orange;
    case TaskStatus.completed:
      return Colors.green;
  }
}

Color priorityColor(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.low:
      return Colors.green;
    case TaskPriority.medium:
      return Colors.orange;
    case TaskPriority.high:
      return Colors.red;
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) =>
      _Pill(text: status.label, color: statusColor(status));
}

class PriorityChip extends StatelessWidget {
  const PriorityChip({super.key, required this.priority});

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) =>
      _Pill(text: priority.label, color: priorityColor(priority));
}

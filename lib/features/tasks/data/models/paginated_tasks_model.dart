import 'package:imaginovation_app/features/tasks/data/models/task_model.dart';
import 'package:imaginovation_app/features/tasks/domain/entities/paginated_tasks.dart';

class PaginatedTasksModel extends PaginatedTasks {
  const PaginatedTasksModel({
    required super.tasks,
    required super.currentPage,
    required super.lastPage,
  });

  factory PaginatedTasksModel.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? <dynamic>[])
        .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = json['meta'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return PaginatedTasksModel(
      tasks: list,
      currentPage: (meta['current_page'] as num?)?.toInt() ?? 1,
      lastPage: (meta['last_page'] as num?)?.toInt() ?? 1,
    );
  }
}

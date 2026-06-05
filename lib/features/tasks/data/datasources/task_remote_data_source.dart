import 'package:intl/intl.dart';

import 'package:imaginovation_app/core/network/dio_client.dart';
import 'package:imaginovation_app/features/tasks/data/models/paginated_tasks_model.dart';
import 'package:imaginovation_app/features/tasks/data/models/task_model.dart';
import 'package:imaginovation_app/features/tasks/domain/entities/task.dart';

abstract class TaskRemoteDataSource {
  Future<PaginatedTasksModel> getTasks({
    required int page,
    required int perPage,
    String? status,
    String? priority,
    String? search,
  });

  Future<TaskModel> getTask(int id);

  Future<TaskModel> createTask({
    required String title,
    String? description,
    required TaskStatus status,
    required TaskPriority priority,
    required DateTime dueDate,
  });

  Future<TaskModel> updateTask(
    int id, {
    required String title,
    String? description,
    required TaskStatus status,
    required TaskPriority priority,
    required DateTime dueDate,
  });

  Future<TaskModel> updateTaskStatus(int id, TaskStatus status);

  Future<void> deleteTask(int id);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  TaskRemoteDataSourceImpl(this._client);

  final DioClient _client;
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Future<PaginatedTasksModel> getTasks({
    required int page,
    required int perPage,
    String? status,
    String? priority,
    String? search,
  }) async {
    try {
      final response = await _client.dio.get(
        '/tasks',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (status != null && status.isNotEmpty) 'status': status,
          if (priority != null && priority.isNotEmpty) 'priority': priority,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      return PaginatedTasksModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw _client.toServerException(e);
    }
  }

  @override
  Future<TaskModel> getTask(int id) async {
    try {
      final response = await _client.dio.get('/tasks/$id');
      return _parse(response.data);
    } catch (e) {
      throw _client.toServerException(e);
    }
  }

  @override
  Future<TaskModel> createTask({
    required String title,
    String? description,
    required TaskStatus status,
    required TaskPriority priority,
    required DateTime dueDate,
  }) async {
    try {
      final response = await _client.dio.post(
        '/tasks',
        data: {
          'title': title,
          'description': description,
          'status': status.apiValue,
          'priority': priority.apiValue,
          'due_date': _dateFormat.format(dueDate),
        },
      );
      return _parse(response.data);
    } catch (e) {
      throw _client.toServerException(e);
    }
  }

  @override
  Future<TaskModel> updateTask(
    int id, {
    required String title,
    String? description,
    required TaskStatus status,
    required TaskPriority priority,
    required DateTime dueDate,
  }) async {
    try {
      final response = await _client.dio.put(
        '/tasks/$id',
        data: {
          'title': title,
          'description': description,
          'status': status.apiValue,
          'priority': priority.apiValue,
          'due_date': _dateFormat.format(dueDate),
        },
      );
      return _parse(response.data);
    } catch (e) {
      throw _client.toServerException(e);
    }
  }

  @override
  Future<TaskModel> updateTaskStatus(int id, TaskStatus status) async {
    try {
      final response = await _client.dio.patch(
        '/tasks/$id/status',
        data: {'status': status.apiValue},
      );
      return _parse(response.data);
    } catch (e) {
      throw _client.toServerException(e);
    }
  }

  @override
  Future<void> deleteTask(int id) async {
    try {
      await _client.dio.delete('/tasks/$id');
    } catch (e) {
      throw _client.toServerException(e);
    }
  }

  TaskModel _parse(dynamic data) {
    final map = data as Map<String, dynamic>;
    return TaskModel.fromJson(map['data'] as Map<String, dynamic>);
  }
}

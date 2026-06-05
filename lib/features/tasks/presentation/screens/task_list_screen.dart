import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:imaginovation_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:imaginovation_app/features/tasks/presentation/bloc/task_list/task_list_bloc.dart';
import 'package:imaginovation_app/features/tasks/presentation/widgets/task_tile.dart';
import 'package:imaginovation_app/injection_container.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TaskListBloc>()..add(const TaskListStarted()),
      child: const _TaskListView(),
    );
  }
}

class _TaskListView extends StatefulWidget {
  const _TaskListView();

  @override
  State<_TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<_TaskListView> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String? _statusFilter;
  String? _priorityFilter;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<TaskListBloc>().add(const TaskListLoadMore());
    }
  }

  void _applyFilters() {
    context.read<TaskListBloc>().add(
          TaskListFiltersChanged(
            status: _statusFilter,
            priority: _priorityFilter,
            search: _searchController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthLogoutRequested()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/tasks/new');
          if (context.mounted) {
            context.read<TaskListBloc>().add(const TaskListRefreshed());
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search tasks...',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              isDense: true,
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                        _applyFilters();
                      },
                    )
                  : null,
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _applyFilters(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: _statusFilter,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(
                        value: 'in_progress', child: Text('In Progress')),
                    DropdownMenuItem(
                        value: 'completed', child: Text('Completed')),
                  ],
                  onChanged: (v) {
                    setState(() => _statusFilter = v);
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: _priorityFilter,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All')),
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                  ],
                  onChanged: (v) {
                    setState(() => _priorityFilter = v);
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return BlocConsumer<TaskListBloc, TaskListState>(
      listener: (context, state) {
        if (state.errorMessage != null &&
            state.status == TaskListStatus.success) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        if (state.status == TaskListStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == TaskListStatus.failure && state.tasks.isEmpty) {
          return _ErrorView(
            message: state.errorMessage ?? 'Failed to load tasks',
            onRetry: () =>
                context.read<TaskListBloc>().add(const TaskListStarted()),
          );
        }
        if (state.tasks.isEmpty) {
          return const Center(child: Text('No tasks yet. Tap + to add one.'));
        }
        return RefreshIndicator(
          onRefresh: () async {
            context.read<TaskListBloc>().add(const TaskListRefreshed());
          },
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 4, bottom: 88),
            itemCount: state.tasks.length + (state.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.tasks.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final task = state.tasks[index];
              return TaskTile(
                task: task,
                onComplete: () => context
                    .read<TaskListBloc>()
                    .add(TaskListItemCompleted(task)),
                onDelete: () => context
                    .read<TaskListBloc>()
                    .add(TaskListItemDeleted(task)),
                onTap: () async {
                  await context.push('/tasks/${task.id}', extra: task);
                  if (context.mounted) {
                    context.read<TaskListBloc>().add(const TaskListRefreshed());
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

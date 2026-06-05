import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'package:imaginovation_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:imaginovation_app/features/auth/presentation/screens/login_screen.dart';
import 'package:imaginovation_app/features/tasks/domain/entities/task.dart';
import 'package:imaginovation_app/features/tasks/presentation/screens/task_detail_screen.dart';
import 'package:imaginovation_app/features/tasks/presentation/screens/task_form_screen.dart';
import 'package:imaginovation_app/features/tasks/presentation/screens/task_list_screen.dart';

class AppRouter {
  AppRouter(this._authBloc);

  final AuthBloc _authBloc;

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: _GoRouterRefreshStream(_authBloc.stream),
    redirect: (context, state) {
      final status = _authBloc.state.status;
      if (status == AuthStatus.unknown) return null;

      final loggedIn = status == AuthStatus.authenticated;
      final onLogin = state.matchedLocation == '/login';

      if (!loggedIn && !onLogin) return '/login';
      if (loggedIn && onLogin) return '/tasks';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/tasks',
        builder: (context, state) => const TaskListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const TaskFormScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return TaskDetailScreen(
                taskId: id,
                initialTask: state.extra as Task?,
              );
            },
          ),
          GoRoute(
            path: ':id/edit',
            builder: (context, state) =>
                TaskFormScreen(task: state.extra as Task?),
          ),
        ],
      ),
    ],
  );
}

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

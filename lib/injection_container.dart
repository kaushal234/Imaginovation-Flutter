import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import 'package:imaginovation_app/core/network/dio_client.dart';
import 'package:imaginovation_app/core/storage/token_storage.dart';
import 'package:imaginovation_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:imaginovation_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:imaginovation_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:imaginovation_app/features/auth/domain/usecases/check_auth_status.dart';
import 'package:imaginovation_app/features/auth/domain/usecases/login.dart';
import 'package:imaginovation_app/features/auth/domain/usecases/logout.dart';
import 'package:imaginovation_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:imaginovation_app/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:imaginovation_app/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:imaginovation_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:imaginovation_app/features/tasks/domain/usecases/create_task.dart';
import 'package:imaginovation_app/features/tasks/domain/usecases/delete_task.dart';
import 'package:imaginovation_app/features/tasks/domain/usecases/get_task.dart';
import 'package:imaginovation_app/features/tasks/domain/usecases/get_tasks.dart';
import 'package:imaginovation_app/features/tasks/domain/usecases/update_task.dart';
import 'package:imaginovation_app/features/tasks/domain/usecases/update_task_status.dart';
import 'package:imaginovation_app/features/tasks/presentation/bloc/task_detail/task_detail_bloc.dart';
import 'package:imaginovation_app/features/tasks/presentation/bloc/task_form/task_form_bloc.dart';
import 'package:imaginovation_app/features/tasks/presentation/bloc/task_list/task_list_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // ---- External ----
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // ---- Core ----
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage(sl()));
  sl.registerLazySingleton<DioClient>(() => DioClient(sl()));

  // ---- Data sources ----
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl(), sl()),
  );
  sl.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(sl()),
  );

  // ---- Repositories ----
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(sl()));

  // ---- Use cases ----
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => Logout(sl()));
  sl.registerLazySingleton(() => CheckAuthStatus(sl()));
  sl.registerLazySingleton(() => GetTasks(sl()));
  sl.registerLazySingleton(() => GetTask(sl()));
  sl.registerLazySingleton(() => CreateTask(sl()));
  sl.registerLazySingleton(() => UpdateTask(sl()));
  sl.registerLazySingleton(() => UpdateTaskStatus(sl()));
  sl.registerLazySingleton(() => DeleteTask(sl()));

  // ---- Blocs ----
  // AuthBloc is a singleton: the router listens to its stream.
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(login: sl(), logout: sl(), checkAuthStatus: sl()),
  );
  // Screen-scoped blocs are factories: a fresh instance per screen.
  sl.registerFactory<TaskListBloc>(
    () => TaskListBloc(
      getTasks: sl(),
      updateTaskStatus: sl(),
      deleteTask: sl(),
    ),
  );
  sl.registerFactory<TaskFormBloc>(
    () => TaskFormBloc(createTask: sl(), updateTask: sl()),
  );
  sl.registerFactory<TaskDetailBloc>(
    () => TaskDetailBloc(getTask: sl(), updateTaskStatus: sl()),
  );
}

import 'package:axel_todo_test/core/config/app_router.dart';
import 'package:axel_todo_test/core/config/app_constanst.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dio/dio.dart';
import '../core/services/file_storage_service.dart';

import '../core/network/network_info.dart';
import '../features/auth/data/datasources/auth_local_data_source.dart';
import '../features/auth/data/models/user_model.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/auth_usecases.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/profile/data/repositories/profile_repository_impl.dart';
import '../features/profile/domain/repositories/profile_repository.dart';
import '../features/profile/domain/usecases/update_profile.dart';
import '../features/profile/presentation/bloc/profile_bloc.dart';
import '../features/todo/data/datasources/todo_local_data_source.dart';

import '../features/todo/data/datasources/todo_remote_data_source.dart';
import '../features/todo/data/models/todo_model.dart';
import '../features/todo/data/repositories/todo_repository_impl.dart';
import '../features/todo/domain/repositories/todo_repository.dart';
import '../features/todo/domain/usecases/todo_usecases.dart';
import '../features/todo/presentation/bloc/todo_bloc.dart';
import '../features/settings/presentation/bloc/settings_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(TodoModelAdapter());

  sl.registerLazySingleton(
    () => AuthBloc(
      loginUser: sl(),
      registerUser: sl(),
      getCurrentUser: sl(),
      logoutUser: sl(),
      getRememberedUser: sl(),
    ),
  );

  sl.registerLazySingleton(() => AppRouter(authBloc: sl()));

  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => GetRememberedUser(sl()));

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDataSource: sl(), fileStorageService: sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(userBox: sl(), sessionBox: sl()),
  );

  sl.registerFactory(
    () => ProfileBloc(getCurrentUser: sl(), updateProfile: sl()),
  );

  sl.registerLazySingleton(() => UpdateProfile(sl()));

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      authLocalDataSource: sl(),
      fileStorageService: sl(),
    ),
  );

  sl.registerFactory(
    () => TodoBloc(getTodos: sl(), toggleFavorite: sl(), searchTodos: sl()),
  );

  sl.registerLazySingleton(() => GetTodos(sl()));
  sl.registerLazySingleton(() => ToggleTodoFavorite(sl()));
  sl.registerLazySingleton(() => SearchTodos(sl()));

  sl.registerLazySingleton<TodoRepository>(
    () => TodoRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<TodoRemoteDataSource>(
    () => TodoRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<TodoLocalDataSource>(
    () => TodoLocalDataSourceImpl(todoBox: sl()),
  );

  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<FileStorageService>(() => FileStorageServiceImpl());

  final userBox = await Hive.openBox<UserModel>(AppConstants.userBox);
  sl.registerLazySingleton(() => userBox);

  final todoBox = await Hive.openBox<TodoModel>(AppConstants.todoBox);
  sl.registerLazySingleton(() => todoBox);

  final sessionBox = await Hive.openBox(AppConstants.sessionBox);
  sl.registerLazySingleton(() => sessionBox);

  final themeBox = await Hive.openBox(AppConstants.themeBox);
  sl.registerSingleton<Box>(themeBox, instanceName: 'theme_box');

  sl.registerFactory(
    () => SettingsBloc(
      themeBox: themeBox,
      todoBox: todoBox,
      sessionBox: sessionBox,
    ),
  );

  sl.registerLazySingleton(() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    return dio;
  });
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());
}

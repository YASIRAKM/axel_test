import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_data_source.dart';
import '../datasources/todo_remote_data_source.dart';
import '../models/todo_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDataSource remoteDataSource;
  final TodoLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  TodoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Todo>>> getTodos(int start, int limit) async {
    if (await networkInfo.isConnected) {
      try {
        return Right(await _fetchAndMergeRemote(start, limit));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return _fetchLocalFallback();
    }
  }

  Future<List<Todo>> _fetchAndMergeRemote(int start, int limit) async {
    final remoteTodos = await remoteDataSource.getTodos(start, limit);
    await localDataSource.cacheTodos(remoteTodos);

    final allLocal = await localDataSource.getLastTodos();
    final localMap = {for (var e in allLocal) e.id: e};

    return remoteTodos.map((r) => localMap[r.id] ?? r).toList();
  }

  Future<Either<Failure, List<Todo>>> _fetchLocalFallback() async {
    try {
      final localTodos = await localDataSource.getLastTodos();
      if (localTodos.isEmpty) {
        return const Left(CacheFailure('No cached data available'));
      }
      return Right(localTodos);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(Todo todo) async {
    return _safeCall(() async {
      final newTodo = TodoModel(
        id: todo.id,
        title: todo.title,
        completed: todo.completed,
        isFavorite: !todo.isFavorite,
      );
      await localDataSource.updateTodo(newTodo);
    });
  }

  @override
  Future<Either<Failure, List<Todo>>> searchTodos(String query) async {
    return _safeCall(() => localDataSource.searchTodos(query));
  }

  Future<Either<Failure, T>> _safeCall<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } catch (e) {
      return const Left(CacheFailure());
    }
  }
}

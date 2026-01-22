import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

class GetTodos implements UseCase<List<Todo>, GetTodosParams> {
  final TodoRepository repository;

  GetTodos(this.repository);

  @override
  Future<Either<Failure, List<Todo>>> call(GetTodosParams params) async {
    return await repository.getTodos(params.start, params.limit);
  }
}

class GetTodosParams extends Equatable {
  final int start;
  final int limit;

  const GetTodosParams({required this.start, required this.limit});

  @override
  List<Object> get props => [start, limit];
}

class ToggleTodoFavorite implements UseCase<void, Todo> {
  final TodoRepository repository;

  ToggleTodoFavorite(this.repository);

  @override
  Future<Either<Failure, void>> call(Todo todo) async {
    return await repository.toggleFavorite(todo);
  }
}

class SearchTodos implements UseCase<List<Todo>, String> {
  final TodoRepository repository;

  SearchTodos(this.repository);

  @override
  Future<Either<Failure, List<Todo>>> call(String query) async {
    return await repository.searchTodos(query);
  }
}

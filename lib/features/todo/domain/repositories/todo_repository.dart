import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/todo.dart';

abstract class TodoRepository {
  Future<Either<Failure, List<Todo>>> getTodos(int start, int limit);
  Future<Either<Failure, void>> toggleFavorite(Todo todo);
  Future<Either<Failure, List<Todo>>> searchTodos(String query);
}

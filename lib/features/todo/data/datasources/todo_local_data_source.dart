import 'package:hive/hive.dart';
import '../models/todo_model.dart';

abstract class TodoLocalDataSource {
  Future<List<TodoModel>> getLastTodos();
  Future<void> cacheTodos(List<TodoModel> todos);
  Future<void> updateTodo(TodoModel todo);
  Future<List<TodoModel>> searchTodos(String query);
}

class TodoLocalDataSourceImpl implements TodoLocalDataSource {
  final Box<TodoModel> todoBox;

  TodoLocalDataSourceImpl({required this.todoBox});

  @override
  Future<List<TodoModel>> getLastTodos() async {
    return todoBox.values.toList();
  }

  @override
  Future<void> cacheTodos(List<TodoModel> todos) async {
    for (var todo in todos) {
      if (todoBox.containsKey(todo.id)) {
        final existing = todoBox.get(todo.id);
        if (existing != null && existing.isFavorite) {
          await todoBox.put(
              todo.id,
              TodoModel(
                id: todo.id,
                title: todo.title,
                completed: todo.completed,
                isFavorite: true,
              ));
          continue;
        }
      }
      await todoBox.put(todo.id, todo);
    }
  }

  @override
  Future<void> updateTodo(TodoModel todo) async {
    await todoBox.put(todo.id, todo);
  }

  @override
  Future<List<TodoModel>> searchTodos(String query) async {
    return todoBox.values
        .where((todo) => todo.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

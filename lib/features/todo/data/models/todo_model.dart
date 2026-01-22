import 'package:hive/hive.dart';
import '../../domain/entities/todo.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 1)
class TodoModel extends Todo {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final bool completed;
  @HiveField(3)
  final bool isFavorite;

  const TodoModel({
    required this.id,
    required this.title,
    required this.completed,
    this.isFavorite = false,
  }) : super(
          id: id,
          title: title,
          completed: completed,
          isFavorite: isFavorite,
        );

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'],
      title: json['title'],
      completed: json['completed'],
      isFavorite: false, 
    );
  }

  factory TodoModel.fromEntity(Todo todo) {
    return TodoModel(
      id: todo.id,
      title: todo.title,
      completed: todo.completed,
      isFavorite: todo.isFavorite,
    );
  }
}

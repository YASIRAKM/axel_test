import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final int id;
  final String title;
  final bool completed;
  final bool isFavorite;

  const Todo({
    required this.id,
    required this.title,
    required this.completed,
    this.isFavorite = false,
  });

  Todo copyWith({
    int? id,
    String? title,
    bool? completed,
    bool? isFavorite,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object> get props => [id, title, completed, isFavorite];
}

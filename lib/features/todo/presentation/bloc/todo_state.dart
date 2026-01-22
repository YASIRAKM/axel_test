part of 'todo_bloc.dart';

abstract class TodoState extends Equatable {
  const TodoState();

  bool get hasReachedMax => false;

  @override
  List<Object> get props => [];
}

class TodoInitial extends TodoState {}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<Todo> todos;
  @override
  final bool hasReachedMax;

  const TodoLoaded({
    this.todos = const <Todo>[],
    this.hasReachedMax = false,
  });

  TodoLoaded copyWith({
    List<Todo>? todos,
    bool? hasReachedMax,
  }) {
    return TodoLoaded(
      todos: todos ?? this.todos,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [todos, hasReachedMax];
}

class TodoError extends TodoState {
  final String message;

  const TodoError({required this.message});

  @override
  List<Object> get props => [message];
}

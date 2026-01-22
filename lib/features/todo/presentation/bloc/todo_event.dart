part of 'todo_bloc.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object> get props => [];
}

class TodoFetched extends TodoEvent {
  final bool isRefresh;
  const TodoFetched({this.isRefresh = false});
}

class TodoSearchChanged extends TodoEvent {
  final String query;
  const TodoSearchChanged(this.query);

  @override
  List<Object> get props => [query];
}

class TodoFavoriteToggled extends TodoEvent {
  final Todo todo;
  const TodoFavoriteToggled(this.todo);

  @override
  List<Object> get props => [todo];
}

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/debounce_transformer.dart';
import '../../domain/entities/todo.dart';
import '../../domain/usecases/todo_usecases.dart';

part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final GetTodos getTodos;
  final ToggleTodoFavorite toggleFavorite;
  final SearchTodos searchTodos;

  TodoBloc({
    required this.getTodos,
    required this.toggleFavorite,
    required this.searchTodos,
  }) : super(TodoInitial()) {
    on<TodoFetched>(_onTodoFetched);
    on<TodoSearchChanged>(
      _onTodoSearchChanged,
      transformer: _debounceTransformer,
    );
    on<TodoFavoriteToggled>(_onTodoFavoriteToggled);
  }


  Stream<T> _debounceTransformer<T>(Stream<T> events, EventMapper<T> mapper) {
    return events
        .transform(DebounceTransformer(const Duration(milliseconds: 300)))
        .asyncExpand(mapper);
  }

  Future<void> _onTodoFetched(
    TodoFetched event,
    Emitter<TodoState> emit,
  ) async {
    if (state.hasReachedMax && !event.isRefresh) return;

    if (state is! TodoLoaded || event.isRefresh) {
      if (event.isRefresh) {
        emit(TodoLoading());
      }
    }

    final currentList = state is TodoLoaded
        ? (state as TodoLoaded).todos
        : <Todo>[];
    final start = event.isRefresh ? 0 : currentList.length;
    final limit = 20;

    final result = await getTodos(GetTodosParams(start: start, limit: limit));

    result.fold((failure) => emit(TodoError(message: failure.message)), (
      todos,
    ) {
      if (event.isRefresh) {
        emit(TodoLoaded(todos: todos, hasReachedMax: todos.length < limit));
      } else {
        emit(
          todos.isEmpty
              ? (state as TodoLoaded).copyWith(hasReachedMax: true)
              : TodoLoaded(
                  todos: currentList + todos,
                  hasReachedMax: todos.length < limit,
                ),
        );
      }
    });
  }

  Future<void> _onTodoSearchChanged(
    TodoSearchChanged event,
    Emitter<TodoState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(TodoFetched(isRefresh: true));
    }
    emit(TodoLoading());
    final result = await searchTodos(event.query);
    result.fold(
      (failure) => emit(TodoError(message: failure.message)),
      (todos) => emit(TodoLoaded(todos: todos, hasReachedMax: true)),
    );
  }

  Future<void> _onTodoFavoriteToggled(
    TodoFavoriteToggled event,
    Emitter<TodoState> emit,
  ) async {
    final result = await toggleFavorite(event.todo);
    if (state is TodoLoaded) {
      final currentTodos = (state as TodoLoaded).todos;
      final updatedTodos = currentTodos.map((t) {
        return t.id == event.todo.id
            ? t.copyWith(isFavorite: !t.isFavorite)
            : t;
      }).toList();
      emit(
        TodoLoaded(
          todos: updatedTodos,
          hasReachedMax: (state as TodoLoaded).hasReachedMax,
        ),
      );
    }

    result.fold(
      (failure) => add(TodoFetched(isRefresh: true)),
      (_) => null,
    );
  }
}

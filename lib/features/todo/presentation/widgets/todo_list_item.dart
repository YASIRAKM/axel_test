import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/todo.dart';
import '../bloc/todo_bloc.dart';

class TodoListItem extends StatelessWidget {
  final Todo todo;

  const TodoListItem({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final statusColor = todo.completed ? Colors.green : Colors.orange;
    final statusBgColor = statusColor.withOpacity(isDark ? 0.2 : 0.1);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: statusBgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            todo.completed ? CupertinoIcons.check_mark : CupertinoIcons.time,
            color: statusColor,
            size: 24,
          ),
        ),
        title: Text(
          todo.title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            decoration: todo.completed ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w600, 
            color: todo.completed
                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            todo.completed ? "Completed" : "Pending",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            todo.isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
            color: todo.isFavorite
                ? Colors.red
                : Theme.of(context).disabledColor,
          ),
          onPressed: () {
            context.read<TodoBloc>().add(TodoFavoriteToggled(todo));
          },
        ),
      ),
    );
  }
}

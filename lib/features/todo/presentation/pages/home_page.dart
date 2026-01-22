import 'package:axel_todo_test/core/config/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../di/injection_container.dart';
import '../bloc/todo_bloc.dart';
import '../widgets/todo_list_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TodoBloc>()..add(const TodoFetched()),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<TodoBloc>().add(const TodoFetched());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<TodoBloc>().add(const TodoFetched(isRefresh: true));
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar.large(
              title: const Text('My Tasks'),
              actions: [
                IconButton(
                  iconSize: 35,
                  icon: const Icon(CupertinoIcons.person_alt_circle),
                  onPressed: () {
                    NavigationService.pushNamed(AppRoutes.profile);
                  },
                ),
                IconButton(
                  iconSize: 35,
                  icon: const Icon(CupertinoIcons.settings),
                  onPressed: () {
                    NavigationService.pushNamed(AppRoutes.settings);
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: const Icon(CupertinoIcons.search),
                  ),
                  onChanged: (value) {
                    context.read<TodoBloc>().add(TodoSearchChanged(value));
                  },
                ),
              ),
            ),

            BlocBuilder<TodoBloc, TodoState>(
              builder: (context, state) {
                if (state is TodoInitial ||
                    (state is TodoLoading && state is! TodoLoaded)) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: TodoSkeleton(),
                      ),
                      childCount: 6,
                    ),
                  );
                } else if (state is TodoError) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: ErrorDisplay(
                        message: state.message,
                        onRetry: () => context.read<TodoBloc>().add(
                          const TodoFetched(isRefresh: true),
                        ),
                      ),
                    ),
                  );
                } else if (state is TodoLoaded) {
                  if (state.todos.isEmpty) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text("No tasks found.")),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= state.todos.length) {
                          return const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: CupertinoActivityIndicator()),
                          );
                        }
                        final todo = state.todos[index];
                        return TodoListItem(todo: todo);
                      },
                      childCount: state.hasReachedMax
                          ? state.todos.length
                          : state.todos.length + 1,
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
          ],
        ),
      ),
    );
  }
}

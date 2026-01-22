import 'package:dio/dio.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/error/exceptions.dart';

import '../models/todo_model.dart';

abstract class TodoRemoteDataSource {
  Future<List<TodoModel>> getTodos(int start, int limit);
}

class TodoRemoteDataSourceImpl implements TodoRemoteDataSource {
  final Dio dio;

  TodoRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<TodoModel>> getTodos(int start, int limit) async {
    
    try {
      final options = Options(
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      );

      final response = await dio.get(
        'https://jsonplaceholder.typicode.com/todos',
        queryParameters: {'_start': start, '_limit': limit},
        options: options,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is! List) {
          throw ServerException('Invalid response format');
        }
        return data
            .map((e) => TodoModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException('Server error: ${response.statusCode}');
      }
    } catch (e) {
      ApiErrorHandler.handle(e);
      throw ServerException(e.toString());
    }
  }
}

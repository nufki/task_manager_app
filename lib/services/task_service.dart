import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_interceptor/http/intercepted_http.dart';

import '../auth/auth_interceptor.dart';
import '../models/task.dart';
import 'auth_service.dart';

class PaginatedTasks {
  final List<Task> tasks;
  final String? nextToken;

  PaginatedTasks({required this.tasks, this.nextToken});
}

class TaskService {
  late final InterceptedHttp _http;
  final AuthService _authService;
  final String taskApi = dotenv.env['TASK_MANAGER_API'] ??
      'https://je08p2822d.execute-api.eu-west-1.amazonaws.com/prod/tasks';

  TaskService(this._authService) {
    _http =
        InterceptedHttp.build(interceptors: [AuthInterceptor(_authService)]);
  }

  Future<PaginatedTasks> fetchTasks({int limit = 10, String? nextToken}) async {
    final queryParams = {'limit': limit.toString()};
    if (nextToken != null) {
      queryParams['nextToken'] = nextToken;
    }

    final uri = Uri.parse(taskApi).replace(queryParameters: queryParams);
    final response = await _http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> items = data['items'];
      final String? newNextToken = data['nextToken'];

      return PaginatedTasks(
        tasks: items.map((item) => _mapToTask(item)).toList(),
        nextToken: newNextToken,
      );
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<Task> addTask(Task task) async {
    final response = await _http.post(
      Uri.parse(taskApi),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': task.name,
        'description': task.description,
        'status': task.status.toJson(),
        'priority': task.priority.toJson(),
        'dueDate': task.dueDate.toIso8601String(),
        'assignedUser': task.assignedUser,
      }),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return _mapToTask(data); // Convert the response to a Task object
    } else {
      throw Exception('Failed to add task');
    }
  }

  Future<Task> updateTask(Task task) async {
    final response = await _http.put(
      Uri.parse('$taskApi/${task.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': task.name,
        'description': task.description,
        'status': task.status.toJson(),
        'priority': task.priority.toJson(),
        'dueDate': task.dueDate.toIso8601String(),
        'assignedUser': task.assignedUser,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return _mapToTask(data); // Convert the response to a Task object
    } else {
      throw Exception('Failed to update task');
    }
  }

  Future<void> deleteTask(String taskId) async {
    await _http.delete(
      Uri.parse('$taskApi/$taskId'), // Include task ID in the endpoint
      headers: {'Content-Type': 'application/json'},
    );
  }

  Task _mapToTask(Map<String, dynamic> item) {
    return Task(
      id: item['id'],
      name: item['name'],
      description: item['description'],
      status: TaskStatusExtension.fromJson(item['status']), // Use fromJson()
      priority:
          TaskPriorityExtension.fromJson(item['priority']), // Use fromJson()
      dueDate: DateTime.parse(item['dueDate']),
      assignedUser: item['assignedUser'],
    );
  }
}

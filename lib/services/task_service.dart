import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_interceptor/http/intercepted_http.dart';

import '../auth/auth_interceptor.dart';
import '../models/task.dart';
import 'auth_service.dart';

class TaskService {
  late final InterceptedHttp _http;
  final AuthService _authService;
  final String taskApi = dotenv.env['TASK_MANAGER_API'] ??
      'https://je08p2822d.execute-api.eu-west-1.amazonaws.com/prod/tasks';

  TaskService(this._authService) {
    _http =
        InterceptedHttp.build(interceptors: [AuthInterceptor(_authService)]);
  }

  Future<List<Task>> fetchAllTasks() async {
    final response = await _http.get(Uri.parse(taskApi));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => _mapToTask(item)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<void> addTask(Task task) async {
    await _http.post(
      Uri.parse(taskApi),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': task.name,
        'description': task.description,
        'status': task.status.toJson(), // Use toJson() from the extension
        'priority': task.priority.toJson(), // Use toJson() from the extension
        'dueDate': task.dueDate.toIso8601String(),
        'assignedUser': task.assignedUser,
      }),
    );
  }

  Future<void> updateTask(Task task) async {
    await _http.put(
      Uri.parse('$taskApi/${task.id}'), // Include task ID in the endpoint
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

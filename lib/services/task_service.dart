import 'dart:convert';

// import 'package:http/http.dart' as http;
import 'package:http_interceptor/http/intercepted_http.dart';

import '../auth/auth_interceptor.dart';
import '../models/task.dart';
import 'auth_service.dart';

class TaskService {
  late final InterceptedHttp _http;
  final AuthService _authService;

  TaskService(this._authService) {
    _http =
        InterceptedHttp.build(interceptors: [AuthInterceptor(_authService)]);
  }

  final String apiUrl =
      'https://je08p2822d.execute-api.eu-west-1.amazonaws.com/prod/tasks';

  Future<List<Task>> fetchAllTasks() async {
    final response = await _http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      print(data);
      return data.map((item) => _mapToTask(item)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<void> addTask(Task task) async {
    await _http.post(
      Uri.parse(apiUrl),
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
      Uri.parse('$apiUrl/${task.id}'), // Include task ID in the endpoint
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
      Uri.parse('$apiUrl/$taskId'), // Include task ID in the endpoint
      headers: {'Content-Type': 'application/json'},
    );
  }

  Task _mapToTask(Map<String, dynamic> item) {
    print('_mapToTask$item');

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

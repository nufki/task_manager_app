import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';

class TaskProvider with ChangeNotifier {
  late final TaskService _taskService;
  final AuthService _authService;
  List<Task> _tasks = [];
  bool _loading = false;
  SortingType _sortingType = SortingType.dueDate;
  SortingType get sortingType => _sortingType;

  List<Task> get tasks => _tasks;
  bool get loading => _loading;

  TaskProvider(this._authService) {
    _taskService = TaskService(_authService);
  }

  Future<void> loadTasks() async {
    _loading = true;
    notifyListeners();

    try {
      _tasks = await _taskService.fetchAllTasks();
    } catch (error) {
      // @Todo
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(Task task) async {
    await _taskService.addTask(task);
    await loadTasks();
  }

  Future<void> updateTask(Task task) async {
    await _taskService.updateTask(task);
    await loadTasks(); // Refresh the tasks after update not sure if there is a smarter way in flutter that just updates the state
  }

  Future<void> deleteTask(String taskId) async {
    await _taskService.deleteTask(taskId);
    await loadTasks(); // Refresh the task list after deletion not sure if there is a smarter way in flutter that just updates the state
  }

  void sortTasks(SortingType type) {
    _sortingType = type;
    _tasks.sort((a, b) {
      switch (type) {
        case SortingType.highestPrio:
          return a.priority.index.compareTo(b.priority.index);
        case SortingType.status:
          return a.status.index.compareTo(b.status.index);
        case SortingType.dueDate:
          return a.dueDate.compareTo(b.dueDate);
      }
    });
    notifyListeners();
  }
}

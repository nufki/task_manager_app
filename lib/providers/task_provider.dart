import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _taskService;
  final AuthService _authService;

  TaskProvider(this._authService) : _taskService = TaskService(_authService);

  List<Task> _tasks = [];
  bool _loading = false;
  SortingType _sortingType = SortingType.dueDate;

  List<Task> get tasks => _tasks;
  bool get loading => _loading;
  SortingType get sortingType => _sortingType;

  Future<void> loadTasks() async {
    _loading = true;
    notifyListeners();

    try {
      _tasks = await _taskService.fetchAllTasks();
    } catch (error) {
      print('Error fetching tasks: $error');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(Task task) async {
    await _taskService.addTask(task);
    await loadTasks();
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

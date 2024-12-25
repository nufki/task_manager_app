import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';

class TaskProvider with ChangeNotifier {
  late final TaskService _taskService;
  final AuthService _authService;
  SortingType _sortingType = SortingType.dueDate;
  SortingType get sortingType => _sortingType;

  List<Task> _tasks = [];
  bool _loading = false;
  bool _isLoadingMore = false;
  String? _nextToken;
  bool hasMore = true;

  List<Task> get tasks => _tasks;
  bool get loading => _loading;
  bool get isLoadingMore => _isLoadingMore;

  TaskProvider(this._authService) {
    _taskService = TaskService(_authService);
  }

  // Load initial tasks
  Future<void> loadTasks() async {
    hasMore = true;
    _loading = true;
    _nextToken = null;
    notifyListeners();

    try {
      final result = await _taskService.fetchTasks(limit: 10);
      _tasks = result.tasks;
      _nextToken = result.nextToken;
    } catch (error) {
      // Handle error
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Load more tasks for pagination
  Future<void> loadMoreTasks() async {
    if (_isLoadingMore || _nextToken == null || !hasMore) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _taskService.fetchTasks(
        limit: 10,
        nextToken: _nextToken,
      );

      _tasks.addAll(result.tasks);
      _nextToken = result.nextToken;
      hasMore = result.nextToken != null;
    } catch (error) {
      // Handle error
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Add a new task directly to the state
  Future<void> addTask(Task task) async {
    try {
      final newTask = await _taskService.addTask(task);
      _tasks.add(newTask);
      _sortTasks();
      notifyListeners();
    } catch (error) {
      // Handle error
    }
  }

  // Update a task directly in the state
  Future<void> updateTask(Task task) async {
    try {
      final updatedTask = await _taskService.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        _sortTasks();
        notifyListeners();
      }
    } catch (error) {
      // Handle error
    }
  }

  // Delete a task and remove it from the state
  Future<void> deleteTask(String taskId) async {
    try {
      await _taskService.deleteTask(taskId);
      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
    } catch (error) {
      // Handle error
    }
  }

  // Sort tasks based on the current sorting type
  void sortTasks(SortingType type) {
    _sortingType = type;
    _sortTasks();
    notifyListeners();
  }

  void _sortTasks() {
    _tasks.sort((a, b) {
      switch (_sortingType) {
        case SortingType.highestPrio:
          return a.priority.index.compareTo(b.priority.index);
        case SortingType.status:
          return a.status.index.compareTo(b.status.index);
        case SortingType.dueDate:
          return a.dueDate.compareTo(b.dueDate);
      }
    });
  }
}

enum TaskPriority { low, medium, high }

enum TaskStatus { notStarted, inProgress, completed }

class Task {
  final String? id;
  final String name;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime dueDate;
  final String? assignedUser;

  Task({
    this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.priority,
    required this.dueDate,
    this.assignedUser,
  });
}

// Extensions for user-friendly labels
extension TaskPriorityExtension on TaskPriority {
  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Low Priority';
      case TaskPriority.medium:
        return 'Medium Priority';
      case TaskPriority.high:
        return 'High Priority';
    }
  }

  String toJson() {
    switch (this) {
      case TaskPriority.low:
        return 'low';
      case TaskPriority.medium:
        return 'medium';
      case TaskPriority.high:
        return 'high';
    }
  }

  static TaskPriority fromJson(String priority) {
    switch (priority) {
      case 'low':
        return TaskPriority.low;
      case 'medium':
        return TaskPriority.medium;
      case 'high':
        return TaskPriority.high;
      default:
        throw Exception('Unknown priority: $priority');
    }
  }
}

extension TaskStatusExtension on TaskStatus {
  String get displayName {
    switch (this) {
      case TaskStatus.notStarted:
        return 'Not Started';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
    }
  }

  String toJson() {
    switch (this) {
      case TaskStatus.notStarted:
        return 'not-started';
      case TaskStatus.inProgress:
        return 'in-progress';
      case TaskStatus.completed:
        return 'completed';
    }
  }

  static TaskStatus fromJson(String status) {
    switch (status) {
      case 'not-started':
        return TaskStatus.notStarted;
      case 'in-progress':
        return TaskStatus.inProgress;
      case 'completed':
        return TaskStatus.completed;
      default:
        throw Exception('Unknown status: $status');
    }
  }
}

enum SortingType { highestPrio, status, dueDate }

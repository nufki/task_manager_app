enum TaskPriority { low, medium, high }

enum TaskStatus { notStarted, inProgress, completed }

enum SortingType { highestPrio, status, dueDate }

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

import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Function(Task task) onViewDetails;
  final Function(Task task) onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onViewDetails,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isPastDue = task.dueDate.isBefore(now);
    final isUnassigned =
        task.assignedUser == null || task.assignedUser!.isEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  task.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // 3-dot menu
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'view_details') {
                      onViewDetails(task);
                    } else if (value == 'delete_task') {
                      onDelete(task);
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'view_details',
                        child: Text('Details'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete_task',
                        child: Text('Delete'),
                      ),
                    ];
                  },
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Due Date: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: _formatDate(task.dueDate),
                    style: TextStyle(
                      color: isPastDue ? Colors.red : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Priority: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: task.priority.displayName),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Status: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: task.status.displayName),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Assigned: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: isUnassigned ? 'Unassigned' : task.assignedUser!,
                    style: TextStyle(
                      color: isUnassigned ? Colors.red : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${_monthAbbreviation(date.month)} ${date.day}, ${date.year}';
  }

  String _monthAbbreviation(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}

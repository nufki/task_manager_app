import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/models/task.dart';
import 'package:task_manager_app/widgets/task_details_form.dart';
import 'package:task_manager_app/widgets/task_helpers.dart';

import '../providers/task_provider.dart';

class TaskList extends StatelessWidget {
  const TaskList({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return ListView.builder(
      itemCount: taskProvider.tasks.length,
      itemBuilder: (context, index) {
        final task = taskProvider.tasks[index];
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
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    // 3-dot menu
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'view_details') {
                          _showTaskDetails(context, task);
                        }
                        if (value == 'delete_task') {
                          _deleteTask(context, task);
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
                            color: isPastDue ? Colors.red : Colors.black),
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
                            color: isUnassigned ? Colors.red : Colors.black),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
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

  void _showTaskDetails(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: TaskDetailsForm(task: task), // Pass the task to the form
      ),
    );
  }

  void _deleteTask(BuildContext context, Task task) {
    showDeleteConfirmationDialog(
        context, task.id!); // Call the outsourced function
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/widgets/task-card.dart';
import 'package:task_manager_app/widgets/task_details_form.dart';
import 'package:task_manager_app/widgets/task_helpers.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        final taskProvider = Provider.of<TaskProvider>(context, listen: false);
        taskProvider.loadMoreTasks();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return ListView.builder(
      controller: _scrollController,
      itemCount: taskProvider.tasks.length + 1, // Add 1 for the footer widget
      itemBuilder: (context, index) {
        if (index < taskProvider.tasks.length) {
          final task = taskProvider.tasks[index];
          return TaskCard(
            task: task,
            onViewDetails: (task) => _showTaskDetails(context, task),
            onDelete: (task) => _deleteTask(context, task),
          );
        } else {
          // Footer widget: loading indicator or "No more tasks" message
          if (taskProvider.isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (!taskProvider.hasMore) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: Text('No more tasks to load.')),
            );
          } else {
            return const SizedBox
                .shrink(); // Empty widget when neither loading nor end
          }
        }
      },
    );
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

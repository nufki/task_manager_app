import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/add_task_form.dart';
import '../widgets/task_list.dart';

class TaskManagerScreen extends StatefulWidget {
  const TaskManagerScreen({super.key});

  @override
  State<TaskManagerScreen> createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<TaskManagerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          // Sorting criteria at the top
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sorting:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                // Wrap the Text in a CupertinoButton to make it clickable
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    _showCupertinoActionSheet(context, taskProvider);
                  },
                  child: Row(
                    children: [
                      Text(
                        taskProvider.sortingType.displayName,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Task list and body
          Expanded(
            child: RefreshIndicator(
              onRefresh: refreshTasks,
              child: taskProvider.loading
                  ? const Center(child: CircularProgressIndicator())
                  : const TaskList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskForm(context),
        tooltip: 'Add New Task',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> refreshTasks() async {
    await Provider.of<TaskProvider>(context, listen: false).loadTasks();
  }

  void fetchTasks() {
    Provider.of<TaskProvider>(context, listen: false).loadTasks();
  }

  void _showAddTaskForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: const AddTaskForm(),
      ),
    );
  }

  // Function to show the CupertinoActionSheet with sorting options
  void _showCupertinoActionSheet(
      BuildContext context, TaskProvider taskProvider) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) {
        return CupertinoActionSheet(
          title: const Text('Select Sorting'),
          message: const Text('Choose how to sort your tasks'),
          actions: SortingType.values.map((SortingType sortingType) {
            return CupertinoActionSheetAction(
              onPressed: () {
                taskProvider.sortTasks(sortingType);
                Navigator.pop(ctx); // Close the action sheet
              },
              child: Text(sortingType.displayName),
            );
          }).toList(),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx); // Close the action sheet
            },
            isDestructiveAction: true,
            child: const Text('Cancel'),
          ),
        );
      },
    );
  }
}

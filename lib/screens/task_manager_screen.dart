import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      appBar: AppBar(title: const Text('Task Manager')),
      body: RefreshIndicator(
        onRefresh: refreshTasks, // Call the refresh function
        child: taskProvider.loading
            ? const Center(child: CircularProgressIndicator())
            : const TaskList(), // Use the TaskList widget here
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
}

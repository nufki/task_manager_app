import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';

class AddTaskForm extends StatefulWidget {
  const AddTaskForm({super.key});

  @override
  State<AddTaskForm> createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<AddTaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _dueDate = DateTime.now();
  TaskPriority _priority = TaskPriority.medium;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Task Name'),
              validator: (value) => value!.isEmpty ? 'Enter a task name' : null,
            ),
            ElevatedButton(
              onPressed: _submitTask,
              child: Text('Add task'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitTask() {
    if (_formKey.currentState!.validate()) {
      final newTask = Task(
        name: _nameController.text,
        description: _descriptionController.text,
        status: TaskStatus.notStarted,
        priority: _priority,
        dueDate: _dueDate,
      );

      Provider.of<TaskProvider>(context, listen: false).addTask(newTask);
      _formKey.currentState!.reset();
    }
  }
}

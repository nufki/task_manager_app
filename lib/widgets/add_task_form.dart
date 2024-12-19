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
  TaskStatus _status = TaskStatus.notStarted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Task Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter a task name' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter a description' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskPriority>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: TaskPriority.values
                    .map((priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(priority.displayName),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _priority = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskStatus>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: TaskStatus.values
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.displayName),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _status = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                    'Due Date: ${_dueDate.toLocal().toString().split(' ')[0]}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDueDate,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.end, // Align buttons to the right
                children: [
                  ElevatedButton(
                    onPressed: _submitTask,
                    child: const Text('Add task'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickDueDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      setState(() => _dueDate = selectedDate);
    }
  }

  void _submitTask() {
    if (_formKey.currentState!.validate()) {
      final newTask = Task(
        name: _nameController.text,
        description: _descriptionController.text,
        status: _status,
        priority: _priority,
        dueDate: _dueDate,
      );

      Provider.of<TaskProvider>(context, listen: false).addTask(newTask);
      Navigator.of(context).pop(); // Close the modal after submission
    }
  }
}

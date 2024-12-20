import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/user_provider.dart';

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
  String? _assignedUser; // Nullable for unassigned user

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.users.isEmpty) {
        userProvider.loadUsers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    // Ensure _assignedUser is valid
    if (_assignedUser != null && !userProvider.users.contains(_assignedUser)) {
      _assignedUser =
          null; // Reset to unassigned if the current value is invalid
    }

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
              Row(
                children: [
                  const Text(
                    'Due Date',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment:
                          Alignment.centerRight, // Align date to the right
                      child: Text(
                        // Manually format the date (yyyy-MM-dd)
                        '${_dueDate.year}-${_dueDate.month.toString().padLeft(2, '0')}-${_dueDate.day.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _pickDueDate,
                  ),
                ],
              ),
              DropdownButtonFormField<String?>(
                value: _assignedUser,
                decoration: const InputDecoration(labelText: 'Assigned user'),
                items: [
                  const DropdownMenuItem(
                    value: null, // Unset user
                    child: Text('Unassigned'),
                  ),
                  ...userProvider.users.map((user) {
                    return DropdownMenuItem(
                      value: user,
                      child: Text(user),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() => _assignedUser = value);
                },
              ),
              if (userProvider.loading)
                const Padding(
                  padding: EdgeInsets.only(
                      right:
                          8), // Add some space between the spinner and dropdown
                  child: LinearProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
                    minHeight: 3.0, // Set the height of the progress bar
                  ),
                ),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.end, // Align buttons to the right
                children: [
                  ElevatedButton(
                    onPressed: _submitTask,
                    child: const Text('Add'),
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
        assignedUser: _assignedUser, // Save the updated user assignment
      );

      Provider.of<TaskProvider>(context, listen: false).addTask(newTask);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task successfully created'),
          duration: Duration(milliseconds: 500),
        ),
      );
      Navigator.of(context).pop(); // Close the modal after submission
    }
  }
}

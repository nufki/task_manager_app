import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/user_provider.dart';

class TaskDetailsForm extends StatefulWidget {
  final Task task;

  const TaskDetailsForm({super.key, required this.task});

  @override
  State<TaskDetailsForm> createState() => _TaskDetailsFormState();
}

class _TaskDetailsFormState extends State<TaskDetailsForm> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late DateTime _dueDate;
  late TaskPriority _priority;
  late TaskStatus _status;
  String? _assignedUser; // Nullable for unassigned user

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.task.name);
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _dueDate = widget.task.dueDate;
    _priority = widget.task.priority;
    _status = widget.task.status;
    _assignedUser = widget.task.assignedUser; // Set the initial assigned user
    // Fetch users after the first frame
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

    // Check if users are loaded
    if (userProvider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Ensure _assignedUser is valid
    if (_assignedUser != null && !userProvider.users.contains(_assignedUser)) {
      _assignedUser =
          null; // Reset to unassigned if the current value is invalid
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
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
              DropdownButtonFormField<String?>(
                value: _assignedUser,
                decoration: const InputDecoration(labelText: 'Assigned User'),
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
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                    'Due Date: ${_dueDate.toLocal().toString().split(' ')[0]}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDueDate,
              ),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.end, // Align buttons to the right
                children: [
                  ElevatedButton(
                    onPressed: _submitTask,
                    child: const Text('Update'),
                  ),
                  const SizedBox(width: 16), // Space between buttons
                  ElevatedButton(
                    onPressed: () => _deleteTask(context),
                    child: const Text('Delete'),
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
    final updatedTask = Task(
      id: widget.task.id,
      name: _nameController.text,
      description: _descriptionController.text,
      status: _status,
      priority: _priority,
      dueDate: _dueDate,
      assignedUser: _assignedUser, // Save the updated user assignment
    );

    Provider.of<TaskProvider>(context, listen: false).updateTask(updatedTask);
    Navigator.of(context).pop(); // Close the modal
  }

  void _deleteTask(BuildContext context) {
    Provider.of<TaskProvider>(context, listen: false)
        .deleteTask(widget.task.id!);
    Navigator.of(context).pop(); // Close the modal
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/widgets/task_helpers.dart';

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
  final _formKey = GlobalKey<FormState>();

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
                    onPressed: () => _deleteTask(context),
                    child: const Text('Delete'),
                  ),
                  const SizedBox(width: 16), // Space between buttons
                  ElevatedButton(
                    onPressed: _submitTask,
                    child: const Text('Update'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task successfully updated'),
          duration: Duration(milliseconds: 500),
        ),
      );
      Navigator.of(context).pop(); // Close the modal
    }
  }

  void _deleteTask(BuildContext context) {
    showDeleteConfirmationDialog(
        context, widget.task.id!); // Call the outsourced function
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';

void showDeleteConfirmationDialog(BuildContext context, String taskId) {
  // Show confirmation dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: <Widget>[
          // Cancel button
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog without deleting
            },
            child: const Text('Cancel'),
          ),
          // OK button to confirm deletion
          TextButton(
            onPressed: () {
              // Proceed with task deletion
              Provider.of<TaskProvider>(context, listen: false)
                  .deleteTask(taskId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Task successfully deleted'),
                  duration: const Duration(milliseconds: 500),
                ),
              );
              Navigator.of(context).pop(); // Close the dialog after deletion
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

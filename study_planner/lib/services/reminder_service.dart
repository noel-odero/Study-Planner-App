// lib/services/reminder_service.dart
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_storage.dart';

class ReminderService {
  // Return tasks whose reminder time is due and not yet shown
  static List<Task> findPendingReminders(List<Task> tasks) {
    final now = DateTime.now();
    return tasks.where((t) {
      if (t.reminderDateTime == null) return false;
      if (t.reminderShown) return false;
      // consider reminders at or before now
      return t.reminderDateTime!.isBefore(now.add(const Duration(seconds: 1)));
    }).toList();
  }

  // Show a dialog for a task reminder
  static void showReminderDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (task.description != null) Text(task.description!),
            const SizedBox(height: 8),
            Text('Due: ${task.dueDate.toLocal().toString().split(' ').first}'),
            if (task.reminderDateTime != null)
              Text('Reminder: ${task.reminderDateTime!.toLocal().toString()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Dismiss'),
          ),
          TextButton(
            onPressed: () async {
              // mark reminder as shown and close
              await TaskStorage.instance.markReminderShown(task.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Mark as shown'),
          ),
        ],
      ),
    );
  }
}

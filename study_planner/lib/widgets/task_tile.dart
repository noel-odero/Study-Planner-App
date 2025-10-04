// lib/widgets/task_tile.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

typedef TaskChanged = void Function(Task updated);
typedef TaskIdCallback = void Function(String id);
typedef TaskEditCallback = Future<void> Function();

class TaskTile extends StatelessWidget {
  final Task task;
  final TaskChanged? onChanged;
  final TaskIdCallback? onDelete;
  final TaskEditCallback? onEdit;

  const TaskTile({
    super.key,
    required this.task,
    this.onChanged,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMM d, yyyy');
    final timeFmt = DateFormat('h:mm a');

    return Card(
      elevation: 2,
      child: ListTile(
        leading: Checkbox(
          value: task.done,
          onChanged: (v) {
            if (onChanged != null) onChanged!(task.copyWith(done: v ?? false));
          },
        ),
        title: Text(
          task.title,
          style: task.done
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateFmt.format(task.dueDate)),
            if (task.reminderDateTime != null)
              Text('Reminder: ${timeFmt.format(task.reminderDateTime!)}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit' && onEdit != null) {
              await onEdit!();
            } else if (value == 'delete' && onDelete != null) {
              onDelete!(task.id);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}

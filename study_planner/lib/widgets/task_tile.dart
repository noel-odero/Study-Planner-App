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
      elevation: 0,
      color: Colors.transparent,
      child: ListTile(
        leading: Checkbox(
          value: task.done,
          onChanged: (v) {
            if (onChanged != null) onChanged!(task.copyWith(done: v ?? false));
          },
          activeColor: Colors.amberAccent,
          checkColor: Colors.black,
          side: BorderSide(color: Colors.white.withOpacity(0.5), width: 2),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            color: task.done ? Colors.white54 : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            decoration: task.done ? TextDecoration.lineThrough : null,
            decorationColor: Colors.white,
            decorationThickness: 2,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              dateFmt.format(task.dueDate),
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            if (task.reminderDateTime != null)
              Text(
                'Reminder: ${timeFmt.format(task.reminderDateTime!)}',
                style: const TextStyle(color: Colors.amberAccent, fontSize: 12),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.white),
          color: Color(0xFF2A2520),
          onSelected: (value) async {
            if (value == 'edit' && onEdit != null) {
              await onEdit!();
            } else if (value == 'delete' && onDelete != null) {
              onDelete!(task.id);
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: const [
                  Icon(Icons.edit, color: Colors.white70, size: 20),
                  SizedBox(width: 12),
                  Text('Edit', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: const [
                  Icon(Icons.delete, color: Colors.redAccent, size: 20),
                  SizedBox(width: 12),
                  Text('Delete', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

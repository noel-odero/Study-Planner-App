// lib/screens/new_task_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_storage.dart';

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedReminderTime;
  String? _editingId;
  final DateFormat _dateFmt = DateFormat.yMd();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // If arguments include a Task, we are editing
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg != null && arg is Task && _editingId == null) {
      _editingId = arg.id;
      _titleCtrl.text = arg.title;
      _descCtrl.text = arg.description ?? '';
      _selectedDate = arg.dueDate;
      if (arg.reminderDateTime != null) {
        final dt = arg.reminderDateTime!;
        _selectedReminderTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (d != null) setState(() => _selectedDate = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (t != null) setState(() => _selectedReminderTime = t);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final id = _editingId ?? DateTime.now().millisecondsSinceEpoch.toString();
    DateTime? reminderDT;
    if (_selectedReminderTime != null) {
      reminderDT = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedReminderTime!.hour,
        _selectedReminderTime!.minute,
      );
    }

    final task = Task(
      id: id,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      dueDate: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      ),
      reminderDateTime: reminderDT,
      done: false,
      reminderShown: false,
    );

    if (_editingId != null) {
      await TaskStorage.instance.updateTask(task);
    } else {
      await TaskStorage.instance.addTask(task);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingId != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Task' : 'New Task')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Title required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('Due date'),
                subtitle: Text(_dateFmt.format(_selectedDate)),
                trailing: IconButton(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today),
                ),
              ),
              ListTile(
                title: const Text('Reminder time (optional)'),
                subtitle: Text(
                  _selectedReminderTime == null
                      ? 'Not set'
                      : _selectedReminderTime!.format(context),
                ),
                trailing: IconButton(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.access_time),
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: _save,
                child: Text(isEditing ? 'Save changes' : 'Create task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 32),
            child: AppBar(
              iconTheme: IconThemeData(size: 28, color: Colors.white),
              title: Text(
                isEditing ? 'Edit Task' : 'New Task',
                style: TextStyle(color: Colors.white, fontSize: 28),
              ),
              backgroundColor: Colors.black,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          padding: const EdgeInsets.all(16), // inner spacing
          decoration: BoxDecoration(
            color: Colors.white, // container background
            borderRadius: BorderRadius.circular(12), // rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  style: const TextStyle(color: Colors.black), // input text
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(color: Colors.black54),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Title required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    labelStyle: TextStyle(color: Colors.black54),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text(
                    'Due date',
                    style: TextStyle(color: Colors.black),
                  ),
                  subtitle: Text(
                    _dateFmt.format(_selectedDate),
                    style: const TextStyle(color: Colors.black87),
                  ),
                  trailing: IconButton(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today, color: Colors.black),
                  ),
                ),
                ListTile(
                  title: const Text(
                    'Reminder time (optional)',
                    style: TextStyle(color: Colors.black),
                  ),
                  subtitle: Text(
                    _selectedReminderTime == null
                        ? 'Not set'
                        : _selectedReminderTime!.format(context),
                    style: const TextStyle(color: Colors.black87),
                  ),
                  trailing: IconButton(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // button background
                  ),
                  child: Text(
                    _editingId != null ? 'Save changes' : 'Create task',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

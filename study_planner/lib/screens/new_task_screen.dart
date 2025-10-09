import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_storage.dart';
import 'dart:ui';

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
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.amberAccent,
              onPrimary: Colors.black,
              surface: Color(0xFF1A1A1A),
              onSurface: Colors.white,
              background: Colors.black,
            ),
            dialogBackgroundColor: Color(0xFF1A1A1A),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.amberAccent),
            ),
          ),
          child: child!,
        );
      },
    );
    if (d != null) setState(() => _selectedDate = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.amberAccent,
              onPrimary: Colors.black,
              surface: Color(0xFF1A1A1A),
              onSurface: Colors.white,
              background: Colors.black,
            ),
            dialogBackgroundColor: Color(0xFF1A1A1A),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.amberAccent),
            ),
          ),
          child: child!,
        );
      },
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
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
        child: Center(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        TextFormField(
                          controller: _titleCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            labelStyle: TextStyle(
                              color: Colors.white70,
                              fontSize: 20.0,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white38),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            errorStyle: TextStyle(color: Colors.amberAccent),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Title required'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            labelStyle: TextStyle(
                              color: Colors.white70,
                              fontSize: 20.0,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white38),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        ListTile(
                          title: const Text(
                            'Due date',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                            ),
                          ),
                          subtitle: Text(
                            _dateFmt.format(_selectedDate),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14.0,
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: _pickDate,
                            icon: const Icon(
                              Icons.calendar_today,
                              color: Colors.white,
                              size: 30.0,
                            ),
                          ),
                        ),
                        ListTile(
                          title: const Text(
                            'Reminder time (optional)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                            ),
                          ),
                          subtitle: Text(
                            _selectedReminderTime == null
                                ? 'Not set'
                                : _selectedReminderTime!.format(context),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14.0,
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: _pickTime,
                            icon: const Icon(
                              Icons.access_time,
                              color: Colors.white,
                              size: 30.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 60),
                        ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amberAccent,
                            minimumSize: const Size(double.infinity, 76),
                          ),
                          child: Text(
                            _editingId != null ? 'Save changes' : 'Create task',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 22.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

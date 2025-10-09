import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskStorage {
  static const String _kTasksKey = 'study_planner_tasks';
  static const String _kRemindersKey = 'study_planner_reminders_enabled';
  static TaskStorage? _instance;
  late SharedPreferences _prefs;

  TaskStorage._();

  static TaskStorage get instance {
    _instance ??= TaskStorage._();
    return _instance!;
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<List<Task>> loadTasks() async {
    final s = _prefs.getString(_kTasksKey);
    if (s == null || s.isEmpty) return [];
    final list = jsonDecode(s) as List<dynamic>;
    return list.map((e) => Task.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final list = tasks.map((t) => t.toMap()).toList();
    await _prefs.setString(_kTasksKey, jsonEncode(list));
  }

  Future<void> addTask(Task task) async {
    final tasks = await loadTasks();
    tasks.add(task);
    await saveTasks(tasks);
  }

  Future<void> updateTask(Task task) async {
    final tasks = await loadTasks();
    final idx = tasks.indexWhere((t) => t.id == task.id);
    if (idx >= 0) {
      tasks[idx] = task;
      await saveTasks(tasks);
    }
  }

  Future<void> deleteTask(String id) async {
    final tasks = await loadTasks();
    tasks.removeWhere((t) => t.id == id);
    await saveTasks(tasks);
  }

  Future<void> markReminderShown(String id) async {
    final tasks = await loadTasks();
    final idx = tasks.indexWhere((t) => t.id == id);
    if (idx >= 0) {
      final t = tasks[idx].copyWith(reminderShown: true);
      tasks[idx] = t;
      await saveTasks(tasks);
    }
  }

  // Settings for reminders toggle
  Future<bool> getRemindersEnabled() async {
    return _prefs.getBool(_kRemindersKey) ?? true;
  }

  Future<void> setRemindersEnabled(bool v) async {
    await _prefs.setBool(_kRemindersKey, v);
  }

  // Helper: returns storage method label for settings UI
  String storageMethodLabel() => 'SharedPreferences';
}

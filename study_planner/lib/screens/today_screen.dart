// lib/screens/today_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/task_storage.dart';
import '../models/task.dart';
import '../routes/app_routes.dart';
import '../widgets/task_tile.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  List<Task> _tasks = [];
  final DateFormat _timeFmt = DateFormat('h:mm a');

  @override
  void initState() {
    super.initState();
    _loadTodayTasks();
  }

  Future<void> _loadTodayTasks() async {
    final all = await TaskStorage.instance.loadTasks();
    final now = DateTime.now();
    final todayTasks = all.where((t) {
      return t.dueDate.year == now.year &&
          t.dueDate.month == now.month &&
          t.dueDate.day == now.day;
    }).toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    setState(() => _tasks = todayTasks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 32),
            child: AppBar(
              title: Text(
                'Today',
                style: TextStyle(color: Colors.white, fontSize: 28),
              ),
              backgroundColor: Colors.black,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadTodayTasks,
        child: _tasks.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Text(
                      'No tasks for today',
                      style: TextStyle(color: Colors.white, fontSize: 24.0),
                    ),
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(24),
                itemBuilder: (context, idx) {
                  final t = _tasks[idx];
                  return TaskTile(
                    task: t,
                    onChanged: (updated) async {
                      await TaskStorage.instance.updateTask(updated);
                      await _loadTodayTasks();
                    },
                    onDelete: (id) async {
                      await TaskStorage.instance.deleteTask(id);
                      await _loadTodayTasks();
                    },
                    onEdit: () async {
                      await Navigator.pushNamed(
                        context,
                        AppRoutes.newTask,
                        arguments: t,
                      );
                      await _loadTodayTasks();
                    },
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemCount: _tasks.length,
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amberAccent,
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.newTask);
          await _loadTodayTasks();
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      unselectedItemColor: Colors.white,
      selectedItemColor: Colors.amberAccent,
      currentIndex: 0,
      onTap: (i) {
        if (i == 1) {
          Navigator.pushReplacementNamed(context, AppRoutes.calendar);
        } else if (i == 2) {
          Navigator.pushReplacementNamed(context, AppRoutes.settings);
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.today), label: 'Today'),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}

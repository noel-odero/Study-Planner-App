// lib/screens/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/task_storage.dart';
import '../models/task.dart';
import '../widgets/task_tile.dart';
import '../routes/app_routes.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<DateTime, List<Task>> _events = {};
  DateTime _focused = DateTime.now();
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> _loadAll() async {
    final all = await TaskStorage.instance.loadTasks();
    final map = <DateTime, List<Task>>{};
    for (var t in all) {
      final key = _normalize(t.dueDate);
      map.putIfAbsent(key, () => []).add(t);
    }
    setState(() => _events = map);
  }

  List<Task> _eventsForDay(DateTime day) {
    return _events[_normalize(day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final selectedTasks = _selected == null ? [] : _eventsForDay(_selected!);
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2035, 12, 31),
            focusedDay: _focused,
            selectedDayPredicate: (d) =>
                _selected != null && isSameDay(d, _selected),
            onDaySelected: (selected, focused) {
              setState(() {
                _selected = selected;
                _focused = focused;
              });
            },
            eventLoader: _eventsForDay,
            calendarStyle: const CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: selectedTasks.isEmpty
                ? const Center(child: Text('No tasks for selected date'))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (context, idx) {
                      final t = selectedTasks[idx];
                      return TaskTile(
                        task: t,
                        onChanged: (updated) async {
                          await TaskStorage.instance.updateTask(updated);
                          await _loadAll();
                        },
                        onDelete: (id) async {
                          await TaskStorage.instance.deleteTask(id);
                          await _loadAll();
                        },
                        onEdit: () async {
                          await Navigator.pushNamed(
                            context,
                            AppRoutes.newTask,
                            arguments: t,
                          );
                          await _loadAll();
                        },
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: selectedTasks.length,
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.newTask);
          await _loadAll();
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1,
      onTap: (i) {
        if (i == 0) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
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

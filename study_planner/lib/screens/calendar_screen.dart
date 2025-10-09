// lib/screens/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/task_storage.dart';
import '../models/task.dart';
import '../widgets/task_tile.dart';
import '../routes/app_routes.dart';
import 'dart:ui';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<DateTime, List<Task>> _events = {};
  DateTime _focused = DateTime.now();
  DateTime? _selected;
  CalendarFormat _calendarFormat = CalendarFormat.week; // Start with week view

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
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 32),
            child: AppBar(
              title: Text(
                'Calendar',
                style: TextStyle(color: Colors.white, fontSize: 28),
              ),
              backgroundColor: Colors.black,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Calendar Container with Glass Effect
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
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
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2035, 12, 31),
                    focusedDay: _focused,
                    calendarFormat: _calendarFormat,
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    selectedDayPredicate: (d) =>
                        _selected != null && isSameDay(d, _selected),
                    onDaySelected: (selected, focused) {
                      setState(() {
                        _selected = selected;
                        _focused = focused;
                      });
                    },
                    eventLoader: _eventsForDay,
                    headerStyle: HeaderStyle(
                      titleTextStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      formatButtonTextStyle: TextStyle(color: Colors.white),
                      formatButtonDecoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      ),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(color: Colors.white70),
                      weekendStyle: TextStyle(color: Colors.white70),
                    ),
                    calendarStyle: CalendarStyle(
                      defaultTextStyle: TextStyle(color: Colors.white),
                      weekendTextStyle: TextStyle(color: Colors.white),
                      outsideTextStyle: TextStyle(color: Colors.white38),
                      todayDecoration: BoxDecoration(
                        color: Colors.amberAccent,
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.amberAccent,
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      markerDecoration: BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Tasks Container with Glass Effect
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
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
                  borderRadius: BorderRadius.circular(14),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: selectedTasks.isEmpty
                        ? Center(
                            child: Text(
                              'No tasks for selected date',
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(8),
                            itemBuilder: (context, idx) {
                              final t = selectedTasks[idx];
                              return Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFF2A2520).withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Color(0xFF4A3F35).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 5,
                                      sigmaY: 5,
                                    ),
                                    child: TaskTile(
                                      task: t,
                                      onChanged: (updated) async {
                                        await TaskStorage.instance.updateTask(
                                          updated,
                                        );
                                        await _loadAll();
                                      },
                                      onDelete: (id) async {
                                        await TaskStorage.instance.deleteTask(
                                          id,
                                        );
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
                                    ),
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemCount: selectedTasks.length,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amberAccent,
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
      backgroundColor: Colors.black,
      selectedItemColor: Colors.amberAccent,
      unselectedItemColor: Colors.white,
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

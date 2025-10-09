// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import '../services/task_storage.dart';
import '../routes/app_routes.dart';
import 'dart:ui';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _remindersEnabled = true;
  String _storageMethod = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await TaskStorage.instance.getRemindersEnabled();
    final storage = TaskStorage.instance.storageMethodLabel();
    setState(() {
      _remindersEnabled = enabled;
      _storageMethod = storage;
    });
  }

  Future<void> _setReminders(bool v) async {
    await TaskStorage.instance.setRemindersEnabled(v);
    setState(() => _remindersEnabled = v);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 32),
            child: AppBar(
              title: const Text(
                'Settings',
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
          padding: const EdgeInsets.all(20),
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
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: ListView(
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Enable Reminders',
                      style: TextStyle(color: Colors.white),
                    ),
                    value: _remindersEnabled,
                    onChanged: (v) => _setReminders(v),
                    activeColor: Colors.amberAccent,
                    activeTrackColor: Colors.amberAccent.withOpacity(0.5),
                    inactiveThumbColor: Colors.white38,
                    inactiveTrackColor: Colors.white24,
                  ),
                  Divider(color: Colors.white.withOpacity(0.2)),
                  ListTile(
                    title: const Text(
                      'Storage',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      _storageMethod,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  Divider(color: Colors.white.withOpacity(0.2)),
                  const ListTile(
                    title: Text('About', style: TextStyle(color: Colors.white)),
                    subtitle: Text(
                      'Study Planner - Flutter assignment',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      unselectedItemColor: Colors.white,
      selectedItemColor: Colors.amberAccent,
      currentIndex: 2,
      onTap: (i) {
        if (i == 0) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        } else if (i == 1) {
          Navigator.pushReplacementNamed(context, AppRoutes.calendar);
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

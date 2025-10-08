// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import '../services/task_storage.dart';
import '../routes/app_routes.dart';

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
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Enable Reminders'),
            value: _remindersEnabled,
            onChanged: (v) => _setReminders(v),
          ),
          ListTile(
            title: const Text('Storage'),
            subtitle: Text(_storageMethod),
          ),
          const Divider(),
          ListTile(
            title: const Text('About'),
            subtitle: const Text('Study Planner - Flutter assignment'),
          ),
        ],
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

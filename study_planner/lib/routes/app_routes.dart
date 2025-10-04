// lib/routes/app_routes.dart
import 'package:flutter/material.dart';
import '../screens/today_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/new_task_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String calendar = '/calendar';
  static const String settings = '/settings';
  static const String newTask = '/new-task';

  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const TodayScreen(),
      calendar: (context) => const CalendarScreen(),
      settings: (context) => const SettingsScreen(),
      newTask: (context) => const NewTaskScreen(),
    };
  }
}

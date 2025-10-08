import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'services/task_storage.dart';
import 'services/reminder_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TaskStorage.instance.init(); // initialize SharedPreferences
  runApp(const StudyPlannerApp());
}

class StudyPlannerApp extends StatelessWidget {
  const StudyPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
    );
  }
}

// A tiny helper route that checks reminders after first frame
// We use a HomeWrapper to perform the reminder check once the app is built.
class HomeWrapper extends StatefulWidget {
  final Widget child;
  const HomeWrapper({super.key, required this.child});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  bool _checked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_checked) {
      // Wait until first frame to check reminders
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final enabled = await TaskStorage.instance.getRemindersEnabled();
        if (enabled) {
          final tasks = await TaskStorage.instance.loadTasks();
          final pending = ReminderService.findPendingReminders(tasks);
          if (pending.isNotEmpty) {
            // show the first pending reminder
            ReminderService.showReminderDialog(context, pending.first);
            // mark as shown
            await TaskStorage.instance.markReminderShown(pending.first.id);
          }
        }
      });
      _checked = true;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
